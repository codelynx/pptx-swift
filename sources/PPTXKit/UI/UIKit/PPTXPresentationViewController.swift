#if canImport(UIKit)
import UIKit

/// A UIViewController for presenting PPTX slides with navigation
public class PPTXPresentationViewController: UIViewController {
	
	// MARK: - Properties
	
	private let manager: PPTXManager
	private var slideView: PPTXSlideView!
	private var navigationBar: UIView!
	private var previousButton: UIButton!
	private var nextButton: UIButton!
	private var slideCounterLabel: UILabel!
	private var progressView: UIProgressView!
	
	// Configuration
	public var showNavigationControls: Bool = true {
		didSet { updateNavigationVisibility() }
	}
	
	public var showProgressBar: Bool = true {
		didSet { updateProgressVisibility() }
	}
	
	public var renderingQuality: RenderingQuality = .balanced {
		didSet { slideView?.renderingQuality = renderingQuality }
	}
	
	// MARK: - Initialization
	
	public init(manager: PPTXManager) {
		self.manager = manager
		super.init(nibName: nil, bundle: nil)
		
		// Set up as delegate
		manager.delegate = self
	}
	
	required init?(coder: NSCoder) {
		self.manager = PPTXManager()
		super.init(coder: coder)
		manager.delegate = self
	}
	
	// MARK: - Lifecycle
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
		updateUI()
		
		// Handle swipe gestures
		setupGestureRecognizers()
	}
	
	// MARK: - UI Setup
	
	private func setupUI() {
		view.backgroundColor = .systemBackground
		
		// Progress view
		progressView = UIProgressView(progressViewStyle: .default)
		progressView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(progressView)
		
		// Slide view
		slideView = PPTXSlideView(frame: .zero)
		slideView.translatesAutoresizingMaskIntoConstraints = false
		slideView.renderingQuality = renderingQuality
		slideView.backgroundColor = .systemGray6
		view.addSubview(slideView)
		
		// Navigation bar
		setupNavigationBar()
		
		// Constraints
		NSLayoutConstraint.activate([
			// Progress view
			progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			
			// Slide view
			slideView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
			slideView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			slideView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			slideView.bottomAnchor.constraint(equalTo: navigationBar.topAnchor, constant: -8),
			
			// Navigation bar
			navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			navigationBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			navigationBar.heightAnchor.constraint(equalToConstant: 60)
		])
	}
	
	private func setupNavigationBar() {
		navigationBar = UIView()
		navigationBar.translatesAutoresizingMaskIntoConstraints = false
		navigationBar.backgroundColor = .systemGray6
		view.addSubview(navigationBar)
		
		// Previous button
		previousButton = UIButton(type: .system)
		previousButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
		previousButton.addTarget(self, action: #selector(previousSlide), for: .touchUpInside)
		previousButton.translatesAutoresizingMaskIntoConstraints = false
		navigationBar.addSubview(previousButton)
		
		// Next button
		nextButton = UIButton(type: .system)
		nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
		nextButton.addTarget(self, action: #selector(nextSlide), for: .touchUpInside)
		nextButton.translatesAutoresizingMaskIntoConstraints = false
		navigationBar.addSubview(nextButton)
		
		// Slide counter
		slideCounterLabel = UILabel()
		slideCounterLabel.textAlignment = .center
		slideCounterLabel.font = .preferredFont(forTextStyle: .headline)
		slideCounterLabel.translatesAutoresizingMaskIntoConstraints = false
		navigationBar.addSubview(slideCounterLabel)
		
		// Menu button
		let menuButton = UIButton(type: .system)
		menuButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
		menuButton.menu = createMenu()
		menuButton.showsMenuAsPrimaryAction = true
		menuButton.translatesAutoresizingMaskIntoConstraints = false
		navigationBar.addSubview(menuButton)
		
		// Constraints
		NSLayoutConstraint.activate([
			previousButton.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 16),
			previousButton.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
			previousButton.widthAnchor.constraint(equalToConstant: 44),
			previousButton.heightAnchor.constraint(equalToConstant: 44),
			
			slideCounterLabel.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 16),
			slideCounterLabel.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
			slideCounterLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
			
			nextButton.leadingAnchor.constraint(equalTo: slideCounterLabel.trailingAnchor, constant: 16),
			nextButton.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
			nextButton.widthAnchor.constraint(equalToConstant: 44),
			nextButton.heightAnchor.constraint(equalToConstant: 44),
			
			menuButton.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -16),
			menuButton.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
			menuButton.widthAnchor.constraint(equalToConstant: 44),
			menuButton.heightAnchor.constraint(equalToConstant: 44)
		])
	}
	
	private func setupGestureRecognizers() {
		// Swipe left for next
		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
		swipeLeft.direction = .left
		view.addGestureRecognizer(swipeLeft)
		
		// Swipe right for previous
		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
		swipeRight.direction = .right
		view.addGestureRecognizer(swipeRight)
		
		// Tap to toggle navigation
		let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		slideView.addGestureRecognizer(tap)
	}
	
	// MARK: - Menu
	
	private func createMenu() -> UIMenu {
		let firstSlide = UIAction(title: "First Slide", image: UIImage(systemName: "backward.end")) { _ in
			self.manager.goToFirst()
		}
		
		let lastSlide = UIAction(title: "Last Slide", image: UIImage(systemName: "forward.end")) { _ in
			self.manager.goToLast()
		}
		
		let slideActions = (1...manager.slideCount).map { index in
			UIAction(title: "Slide \(index)") { _ in
				self.manager.goToSlide(at: index)
			}
		}
		
		let goToMenu = UIMenu(title: "Go to Slide", children: slideActions)
		
		return UIMenu(children: [firstSlide, lastSlide, goToMenu])
	}
	
	// MARK: - Actions
	
	@objc private func previousSlide() {
		manager.goToPrevious()
	}
	
	@objc private func nextSlide() {
		manager.goToNext()
	}
	
	@objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
		switch gesture.direction {
		case .left:
			manager.goToNext()
		case .right:
			manager.goToPrevious()
		default:
			break
		}
	}
	
	@objc private func handleTap(_ gesture: UITapGestureRecognizer) {
		// Toggle navigation visibility
		showNavigationControls.toggle()
	}
	
	// MARK: - UI Updates
	
	private func updateUI() {
		// Update slide view
		if let slide = manager.currentSlide {
			slideView = PPTXSlideView(slide: slide, frame: slideView.frame)
			slideView.renderingQuality = renderingQuality
		}
		
		// Update navigation
		previousButton.isEnabled = manager.canGoPrevious
		nextButton.isEnabled = manager.canGoNext
		slideCounterLabel.text = "\(manager.currentSlideIndex) / \(manager.slideCount)"
		
		// Update progress
		progressView.progress = Float(manager.progress)
		
		// Update menu
		if let menuButton = navigationBar.subviews.compactMap({ $0 as? UIButton }).last {
			menuButton.menu = createMenu()
		}
	}
	
	private func updateNavigationVisibility() {
		UIView.animate(withDuration: 0.3) {
			self.navigationBar.alpha = self.showNavigationControls ? 1.0 : 0.0
		}
	}
	
	private func updateProgressVisibility() {
		UIView.animate(withDuration: 0.3) {
			self.progressView.alpha = self.showProgressBar ? 1.0 : 0.0
		}
	}
}

// MARK: - PPTXManagerDelegate

extension PPTXPresentationViewController: PPTXManagerDelegate {
	public func pptxManager(_ manager: PPTXManager, didLoadPresentationWithSlideCount count: Int) {
		updateUI()
	}
	
	public func pptxManager(_ manager: PPTXManager, didNavigateFrom oldIndex: Int, to newIndex: Int) {
		updateUI()
	}
	
	public func pptxManager(_ manager: PPTXManager, didEncounterError error: Error) {
		let alert = UIAlertController(
			title: "Error",
			message: error.localizedDescription,
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}
}

// MARK: - Thumbnail Collection View Controller

/// A collection view controller showing slide thumbnails
public class PPTXThumbnailViewController: UICollectionViewController {
	private let manager: PPTXManager
	private let cellIdentifier = "SlideCell"
	
	public init(manager: PPTXManager) {
		self.manager = manager
		
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 200, height: 180)
		layout.minimumInteritemSpacing = 16
		layout.minimumLineSpacing = 16
		layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		
		super.init(collectionViewLayout: layout)
	}
	
	required init?(coder: NSCoder) {
		self.manager = PPTXManager()
		super.init(coder: coder)
		manager.delegate = self
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView.backgroundColor = .systemBackground
		collectionView.register(SlideCell.self, forCellWithReuseIdentifier: cellIdentifier)
		
		manager.delegate = self
	}
	
	// MARK: - Collection View Data Source
	
	public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return manager.slideCount
	}
	
	public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! SlideCell
		
		if let slide = manager.slide(at: indexPath.item + 1) {
			cell.configure(with: slide, index: indexPath.item + 1, isSelected: manager.currentSlideIndex == indexPath.item + 1)
		}
		
		return cell
	}
	
	// MARK: - Collection View Delegate
	
	public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		manager.goToSlide(at: indexPath.item + 1)
		collectionView.reloadData()
	}
	
	// MARK: - Slide Cell
	
	private class SlideCell: UICollectionViewCell {
		private var slideView: PPTXSlideView!
		private var indexLabel: UILabel!
		private var titleLabel: UILabel!
		
		override init(frame: CGRect) {
			super.init(frame: frame)
			setupUI()
		}
		
		required init?(coder: NSCoder) {
			super.init(coder: coder)
			setupUI()
		}
		
		private func setupUI() {
			contentView.backgroundColor = .systemGray6
			contentView.layer.cornerRadius = 8
			
			slideView = PPTXSlideView(frame: .zero)
			slideView.translatesAutoresizingMaskIntoConstraints = false
			slideView.renderingQuality = .low
			contentView.addSubview(slideView)
			
			indexLabel = UILabel()
			indexLabel.font = .preferredFont(forTextStyle: .caption1)
			indexLabel.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(indexLabel)
			
			titleLabel = UILabel()
			titleLabel.font = .preferredFont(forTextStyle: .caption2)
			titleLabel.textColor = .secondaryLabel
			titleLabel.numberOfLines = 2
			titleLabel.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(titleLabel)
			
			NSLayoutConstraint.activate([
				slideView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
				slideView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
				slideView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
				slideView.heightAnchor.constraint(equalToConstant: 120),
				
				indexLabel.topAnchor.constraint(equalTo: slideView.bottomAnchor, constant: 8),
				indexLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
				indexLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
				
				titleLabel.topAnchor.constraint(equalTo: indexLabel.bottomAnchor, constant: 4),
				titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
				titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
			])
		}
		
		func configure(with slide: Slide, index: Int, isSelected: Bool) {
			slideView = PPTXSlideView(slide: slide, frame: slideView.frame)
			indexLabel.text = "Slide \(index)"
			titleLabel.text = slide.title ?? ""
			
			contentView.layer.borderWidth = isSelected ? 3 : 0
			contentView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
		}
	}
}

// MARK: - Delegate

extension PPTXThumbnailViewController: PPTXManagerDelegate {
	public func pptxManager(_ manager: PPTXManager, didLoadPresentationWithSlideCount count: Int) {
		collectionView.reloadData()
	}
	
	public func pptxManager(_ manager: PPTXManager, didNavigateFrom oldIndex: Int, to newIndex: Int) {
		collectionView.reloadData()
	}
	
	public func pptxManager(_ manager: PPTXManager, didEncounterError error: Error) {
		// Handle error
	}
}

#endif