import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import AVFoundation
import Photos

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    let friend: UserProfile
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var me: UserProfile? { didSet { inputBar.me = me } }
    var messages: [HabitMessage] = []
    var listener: ListenerRegistration?

    let tableView = UITableView(frame: .zero, style: .plain)
    let inputBar = MessageInputBar()
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?

    init(friend: UserProfile) {
        self.friend = friend
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupTableView()
        setupInputBar()
        listenForMessages()
        title = friend.displayName
    }
    deinit { listener?.remove() }

    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "chatcell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -64)
        ])
    }

    func setupInputBar() {
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputBar)
        inputBar.delegate = self
        NSLayoutConstraint.activate([
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            inputBar.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatcell", for: indexPath) as! ChatMessageCell
        cell.configure(with: msg, isMe: msg.senderId == me?.uid, parent: self)
        return cell
    }
    func scrollToBottom(animated: Bool = true) {
        guard messages.count > 0 else { return }
        let lastRow = messages.count - 1
        guard lastRow >= 0, lastRow < tableView.numberOfRows(inSection: 0) else { return }
        let idx = IndexPath(row: lastRow, section: 0)
        tableView.scrollToRow(at: idx, at: .bottom, animated: animated)
    }

    func listenForMessages() {
        guard let myUid = me?.uid else { return }
        let chatId = chatID(me: myUid, friend: friend.uid)
        listener = db.collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snap, _ in
                guard let self = self else { return }
                self.messages = snap?.documents.compactMap { HabitMessage(from: $0.data()) } ?? []
                self.tableView.reloadData()
                self.scrollToBottom()
            }
    }
    func sendMessage(_ message: HabitMessage) {
        guard let myUid = me?.uid else { return }
        let chatId = chatID(me: myUid, friend: friend.uid)
        db.collection("chats").document(chatId).collection("messages").document(message.id).setData(message.dictionary)
    }
    func chatID(me: String, friend: String) -> String {
        return [me, friend].sorted().joined(separator: "_")
    }

    func startRecording() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("msg-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            recorder = nil
        }
    }
    func stopRecording() {
        recorder?.stop()
        guard let url = recorder?.url else { return }
        uploadAudio(url: url)
    }
    func uploadAudio(url: URL) {
        guard let myUid = me?.uid else { return }
        let ref = storage.reference().child("chatAudio/\(UUID().uuidString).m4a")
        ref.putFile(from: url, metadata: nil) { [weak self] meta, error in
            guard let self = self, error == nil else { return }
            ref.downloadURL { url, error in
                guard let url = url else { return }
                let msg = HabitMessage(
                    id: UUID().uuidString,
                    senderId: myUid,
                    timestamp: Date(),
                    type: MessageType.voice,
                    content: nil,
                    audioURL: url.absoluteString,
                    checkinData: nil,
                    summaryData: nil,
                    pollData: nil,
                    reactions: nil
                )
                self.sendMessage(msg)
            }
        }
    }
    func playAudio(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
        } catch {}
    }

    func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let img = info[.originalImage] as? UIImage else { return }
        uploadImage(img)
    }
    func uploadImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85), let myUid = me?.uid else { return }
        let ref = storage.reference().child("chatImages/\(UUID().uuidString).jpg")
        ref.putData(data, metadata: nil) { [weak self] meta, error in
            guard let self = self, error == nil else { return }
            ref.downloadURL { url, error in
                guard let url = url else { return }
                let msg = HabitMessage(
                    id: UUID().uuidString,
                    senderId: myUid,
                    timestamp: Date(),
                    type: MessageType.image,
                    content: url.absoluteString,
                    audioURL: nil,
                    checkinData: nil,
                    summaryData: nil,
                    pollData: nil,
                    reactions: nil
                )
                self.sendMessage(msg)
            }
        }
    }

    func sendSummaryCard(_ summary: SummaryData) {
        guard let myUid = me?.uid else { return }
        let msg = HabitMessage(
            id: UUID().uuidString,
            senderId: myUid,
            timestamp: Date(),
            type: MessageType.summary,
            content: nil,
            audioURL: nil,
            checkinData: nil,
            summaryData: summary,
            pollData: nil,
            reactions: nil
        )
        sendMessage(msg)
    }
}

extension ChatViewController: MessageInputBarDelegate {
    func didSendText(_ text: String) {
        guard let myUid = me?.uid else { return }
        let msg = HabitMessage(
            id: UUID().uuidString,
            senderId: myUid,
            timestamp: Date(),
            type: MessageType.text,
            content: text,
            audioURL: nil,
            checkinData: nil,
            summaryData: nil,
            pollData: nil,
            reactions: nil
        )
        sendMessage(msg)
    }
    func didTapPhoto() {
        presentImagePicker()
    }
    func didStartRecording() {
        startRecording()
    }
    func didStopRecording() {
        stopRecording()
    }
    func didSendCheckin(_ checkin: CheckinData) {
        guard let myUid = me?.uid else { return }
        let msg = HabitMessage(
            id: UUID().uuidString,
            senderId: myUid,
            timestamp: Date(),
            type: MessageType.checkin,
            content: nil,
            audioURL: nil,
            checkinData: checkin,
            summaryData: nil,
            pollData: nil,
            reactions: nil
        )
        sendMessage(msg)
    }
    func didSendNudge(_ nudge: String) {
        guard let myUid = me?.uid else { return }
        let msg = HabitMessage(
            id: UUID().uuidString,
            senderId: myUid,
            timestamp: Date(),
            type: MessageType.nudge,
            content: nudge,
            audioURL: nil,
            checkinData: nil,
            summaryData: nil,
            pollData: nil,
            reactions: nil
        )
        sendMessage(msg)
    }
    func didSendSummary(_ summary: SummaryData) {
        sendSummaryCard(summary)
    }
}
