import UIKit
import FirebaseFirestore
import FirebaseStorage
import AVFoundation

class ChatViewController: UIViewController {
    // MARK: - Properties
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var listener: ListenerRegistration?
    private var me: UserProfile!
    private let friend: UserProfile
    private var messages: [HabitMessage] = []

    // UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let inputBar = MessageInputBar()
    private let headerView = ChatHeaderView()
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var fullScreenImageView: UIImageView?
    private var currentlyPlayingCell: ChatMessageCell?
    private var currentlyPlayingIndexPath: IndexPath?

    // MARK: - Init
    init(friend: UserProfile, me: UserProfile) {
        self.friend = friend
        self.me = me
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()

        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerView)
        view.addSubview(tableView)
        view.addSubview(inputBar)

        setupHeader()
        setupTableView()
        setupInputBar()
        setupConstraints()

        view.bringSubviewToFront(inputBar)
        listenForMessages()
        headerView.bindToUserStatus(uid: friend.uid)
    }

    deinit { listener?.remove(); headerView.unbindStatus() }

    // MARK: - UI Setup
    private func setupBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1).cgColor,
            UIColor(red: 0.92, green: 0.96, blue: 1.0, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.05, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = view.bounds
        gradient.isGeometryFlipped = false
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setupHeader() {
        headerView.configure(
            name: friend.displayName,
            avatar: ChatMessageCell.avatarImageForName(friend.displayName),
            subtitle: "Loading..."
        )
        headerView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.keyboardDismissMode = .interactive
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "chatcell")
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupInputBar() {
        inputBar.delegate = self
        inputBar.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 62),

            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor),

            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputBar.heightAnchor.constraint(greaterThanOrEqualToConstant: 62)
        ])
    }
}

// MARK: - TableView
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ t: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ t: UITableView, cellForRowAt idx: IndexPath) -> UITableViewCell {
        let msg = messages[idx.row]
        let cell = t.dequeueReusableCell(withIdentifier: "chatcell", for: idx) as! ChatMessageCell
        cell.delegate = self
        let kind = chatKind(from: msg)
        let isMe = msg.senderId == me.uid
        cell.configure(kind: kind, isOutgoing: isMe)
        // If this is the currently playing audio cell, keep playing UI
        if idx == currentlyPlayingIndexPath {
            cell.setPlaying(player?.isPlaying == true)
        } else {
            cell.setPlaying(false)
        }
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let cells = tableView.visibleCells
        for cell in cells {
            let rect = tableView.convert(cell.frame, to: tableView.superview)
            let dist = abs(rect.midY - tableView.frame.midY)
            cell.alpha = max(0.8, 1 - dist/800)
        }
    }
    func scrollToBottom(animated: Bool = true) {
        guard messages.count > 0 else { return }
        let last = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: last, at: .bottom, animated: animated)
    }
}

// MARK: - HabitMessage to ChatMessageKind
extension ChatViewController {
    func chatKind(from msg: HabitMessage) -> ChatMessageKind {
        switch msg.type {
        case .text:
            return .text(msg.content ?? "")
        case .image:
            if let urlString = msg.content, let url = URL(string: urlString) {
                return .photo(url)
            }
            return .text("Photo")
        case .voice:
            if let urlString = msg.audioURL, let url = URL(string: urlString) {
                return .voice(url: url, duration: 0)
            }
            return .text("Voice")
        default:
            return .text("Unsupported")
        }
    }
}

// MARK: - Firebase
extension ChatViewController {
    func listenForMessages() {
        let chatId = chatID(me: me.uid, friend: friend.uid)
        listener = db.collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snap, error in
                if let error = error {
                    print("[ChatViewController] Firestore error:", error)
                }
                guard let self = self else { return }
                let newMessages = snap?.documents.compactMap { doc -> HabitMessage? in
                    let message = HabitMessage(from: doc.data())
                    if message == nil {
                        print("[ChatViewController] Failed to parse message:", doc.data())
                    }
                    return message
                } ?? []
                self.messages = newMessages
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToBottom(animated: false)
                }
            }
    }
    func sendMessage(_ message: HabitMessage) {
        let chatId = chatID(me: me.uid, friend: friend.uid)
        db.collection("chats").document(chatId).collection("messages").document(message.id).setData(message.dictionary)
    }
    func chatID(me: String, friend: String) -> String {
        let id = [me, friend].sorted().joined(separator: "_")
        return id
    }
}

// MARK: - Media & Voice
extension ChatViewController {
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
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        let ref = storage.reference().child("chatImages/\(UUID().uuidString).jpg")
        ref.putData(data, metadata: nil) { [weak self] meta, error in
            guard let self = self, error == nil else { return }
            ref.downloadURL { url, _ in
                guard let url = url else { return }
                let msg = HabitMessage(
                    id: UUID().uuidString, senderId: self.me.uid, timestamp: Date(),
                    type: .image, content: url.absoluteString,
                    audioURL: nil, checkinData: nil, summaryData: nil, pollData: nil, reactions: nil
                )
                self.sendMessage(msg)
            }
        }
    }
    func startRecording() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            guard granted, let self = self else { return }
            DispatchQueue.main.async {
                do {
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(.playAndRecord, mode: .default)
                    try session.setActive(true)
                    let url = FileManager.default.temporaryDirectory.appendingPathComponent("msg-\(UUID().uuidString).m4a")
                    let settings: [String: Any] = [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 12000,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                    ]
                    self.recorder = try AVAudioRecorder(url: url, settings: settings)
                    self.recorder?.record()
                } catch {
                    print("[ChatViewController] Audio recording error: \(error)")
                }
            }
        }
    }
    func stopRecording(cancelled: Bool) {
        recorder?.stop()
        guard !cancelled, let url = recorder?.url else { return }
        let ref = storage.reference().child("chatAudio/\(UUID().uuidString).m4a")
        ref.putFile(from: url, metadata: nil) { [weak self] meta, error in
            guard let self = self, error == nil else { return }
            ref.downloadURL { url, _ in
                guard let url = url else { return }
                let msg = HabitMessage(
                    id: UUID().uuidString, senderId: self.me.uid, timestamp: Date(),
                    type: .voice, content: nil, audioURL: url.absoluteString,
                    checkinData: nil, summaryData: nil, pollData: nil, reactions: nil
                )
                self.sendMessage(msg)
            }
        }
    }
}

// MARK: - MessageInputBarDelegate
extension ChatViewController: MessageInputBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func didSendText(_ text: String) {
        let msg = HabitMessage(
            id: UUID().uuidString, senderId: me.uid, timestamp: Date(),
            type: .text, content: text,
            audioURL: nil, checkinData: nil, summaryData: nil, pollData: nil, reactions: nil
        )
        sendMessage(msg)
    }
    func didTapPhoto() { presentImagePicker() }
    func didStartRecording() { startRecording() }
    func didStopRecording(cancelled: Bool) { stopRecording(cancelled: cancelled) }
    func didSendCheckin(_ checkin: CheckinData) {
        let msg = HabitMessage(
            id: UUID().uuidString, senderId: me.uid, timestamp: Date(),
            type: .checkin, content: nil, audioURL: nil,
            checkinData: checkin, summaryData: nil, pollData: nil, reactions: nil
        )
        sendMessage(msg)
    }
    func didSendNudge(_ nudge: String) {
        let msg = HabitMessage(
            id: UUID().uuidString, senderId: me.uid, timestamp: Date(),
            type: .nudge, content: nudge, audioURL: nil,
            checkinData: nil, summaryData: nil, pollData: nil, reactions: nil
        )
        sendMessage(msg)
    }
    func didSendSummary(_ summary: SummaryData) {
        let msg = HabitMessage(
            id: UUID().uuidString, senderId: me.uid, timestamp: Date(),
            type: .summary, content: nil, audioURL: nil,
            checkinData: nil, summaryData: summary, pollData: nil, reactions: nil
        )
        sendMessage(msg)
    }
}

// MARK: - ChatMessageCellDelegate for interactive image/audio
extension ChatViewController: ChatMessageCellDelegate {
    
    func chatMessageCellShouldStopAudio(_ cell: ChatMessageCell) {
        // Stop audio playback if this cell is currently playing
        if currentlyPlayingCell == cell {
            player?.stop()
            cell.setPlaying(false)
            currentlyPlayingCell = nil
            currentlyPlayingIndexPath = nil
        }
    }
    
    func chatMessageCell(_ cell: ChatMessageCell, didTapImage image: UIImage) {
        let v = UIImageView(image: image)
        v.contentMode = .scaleAspectFit
        v.backgroundColor = .black
        v.frame = view.bounds
        v.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullScreenImage))
        v.addGestureRecognizer(tap)
        fullScreenImageView = v
        view.addSubview(v)
    }
    @objc private func dismissFullScreenImage() {
        fullScreenImageView?.removeFromSuperview()
        fullScreenImageView = nil
    }
    func chatMessageCell(_ cell: ChatMessageCell, didTapAudio url: URL) {
        // Only one audio at a time:
        if let playingCell = currentlyPlayingCell, playingCell != cell {
            playingCell.setPlaying(false)
            player?.stop()
        }
        do {
            // If url is a remote (http(s)), download to a temp file first:
            if url.isFileURL {
                player = try AVAudioPlayer(contentsOf: url)
            } else {
                // Download to a temp file
                let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
                URLSession.shared.downloadTask(with: url) { tempUrl, resp, error in
                    if let tempUrl = tempUrl {
                        DispatchQueue.main.async {
                            do {
                                self.player = try AVAudioPlayer(contentsOf: tempUrl)
                                self.player?.delegate = self
                                self.player?.prepareToPlay()
                                self.player?.play()
                                cell.setPlaying(true)
                                self.currentlyPlayingCell = cell
                                if let idx = self.tableView.indexPath(for: cell) {
                                    self.currentlyPlayingIndexPath = idx
                                }
                            } catch {
                                print("[ChatViewController] audio play error: \(error)")
                            }
                        }
                    } else {
                        print("[ChatViewController] audio download error: \(error?.localizedDescription ?? "unknown error")")
                    }
                }.resume()
                return
            }
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            cell.setPlaying(true)
            currentlyPlayingCell = cell
            if let indexPath = tableView.indexPath(for: cell) {
                currentlyPlayingIndexPath = indexPath
            }
        } catch {
            print("[ChatViewController] audio play error: \(error)")
        }
    }
}

extension ChatViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let cell = currentlyPlayingCell {
            cell.setPlaying(false)
        }
        currentlyPlayingCell = nil
        currentlyPlayingIndexPath = nil
    }
}
