
import UIKit

class  SyncPageControlWithViewController: UIPageViewController {

    var pages = [UIViewController]()
   
    let pageControl = UIPageControl()
    let initialPage = 0

    // animations
    var pageControlBottomAnchor: NSLayoutConstraint?
    var skipButtonTopAnchor: NSLayoutConstraint?
    var nextButtonTopAnchor: NSLayoutConstraint?
    
    private lazy var skipButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Skip", for: .normal)
       
        return button
    }()
    private lazy var nextButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Next", for: .normal)
        return button
    }()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onboardingSetup()
        layout()
        style()
    }
}

extension  SyncPageControlWithViewController {
    
    func onboardingSetup() {
        dataSource = self
        delegate = self
        
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)

        let page1 = OnboardingViewController(model:.init(imageName: "onboarding-img-1",
                                                   titleText: "Welcome",
                                                   subtitleLabel: "To Healthy."))
        let page2 = OnboardingViewController(model:.init(imageName: "onboarding-img-2",
                                             titleText: "",
                                                         subtitleLabel: ""))
        let page3 = OnboardingViewController(model:.init(imageName: "onboarding-img-3",
                                             titleText: "Have fun",
                                                         subtitleLabel: ""))

        [page1,page2,page3].forEach {pages.append($0)}

        setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
    }
    
    
    func style() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .black
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = initialPage
       
    }
    
    func layout() {
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        view.addSubview(skipButton)
        
        NSLayoutConstraint.activate([
            pageControl.widthAnchor.constraint(equalTo: view.widthAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            
            skipButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),

            
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: nextButton.trailingAnchor, multiplier: 2),
        ])
        
        // for animations
        pageControlBottomAnchor = view.bottomAnchor.constraint(equalToSystemSpacingBelow: pageControl.bottomAnchor, multiplier: 2)
        skipButtonTopAnchor = skipButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2)
        nextButtonTopAnchor = nextButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2)
        
        pageControlBottomAnchor?.isActive = true
        skipButtonTopAnchor?.isActive = true
        nextButtonTopAnchor?.isActive = true
    }
}

// MARK: - DataSource

extension  SyncPageControlWithViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        if currentIndex == 0 {
            return pages.last               // wrap last
        } else {
            return pages[currentIndex - 1]  // go previous
        }
    }
        
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }

        if currentIndex < pages.count - 1 {
            return pages[currentIndex + 1]  // go next
        } else {
            return pages.first              // wrap first
        }
    }
}

// MARK: - Delegates

extension  SyncPageControlWithViewController: UIPageViewControllerDelegate {
    
    // How we keep our pageControl in sync with viewControllers
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let currentIndex = pages.firstIndex(of: viewControllers[0]) else { return }
        
        pageControl.currentPage = currentIndex
        animateControlsIfNeeded()
    }
    
    private func animateControlsIfNeeded() {
        let lastPage = pageControl.currentPage == pages.count - 1
        
        if lastPage {
            hideControls()
        } else {
            showControls()
        }

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func hideControls() {
        pageControlBottomAnchor?.constant = CGFloat(Constants.hideControlsInPageControlBottomAnchor)
        skipButtonTopAnchor?.constant = CGFloat(Constants.hideControlsInSkipButtonTopAnchor)
        nextButtonTopAnchor?.constant = CGFloat(Constants.hideControlsInNextButtonTopAnchor)
    }

    private func showControls() {
        pageControlBottomAnchor?.constant = CGFloat(Constants.showControlsINPageControlBottomAnchor)
        skipButtonTopAnchor?.constant = CGFloat(Constants.showControlsINSkipButtonTopAnchor)
        nextButtonTopAnchor?.constant = CGFloat(Constants.showControlsINNextButtonTopAnchor)
    }
}

// MARK: - Actions

extension  SyncPageControlWithViewController {

    @objc func pageControlTapped(_ sender: UIPageControl) {
        setViewControllers([pages[sender.currentPage]], direction: .forward, animated: true, completion: nil)
        animateControlsIfNeeded()
    }

    @objc func skipTapped(_ sender: UIButton) {
        let lastPage = pages.count - 1
        pageControl.currentPage = lastPage
        
        goToSpecificPage(index: lastPage, ofViewControllers: pages)
        animateControlsIfNeeded()
    }
    
    @objc func nextTapped(_ sender: UIButton) {
        pageControl.currentPage += 1
        goToNextPage()
        animateControlsIfNeeded()
    }
}

// MARK: - Extensions

extension UIPageViewController {

    func goToNextPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard let currentPage = viewControllers?[0] else { return }
        guard let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentPage) else { return }
        
        setViewControllers([nextPage], direction: .forward, animated: animated, completion: completion)
    }
    
    func goToPreviousPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard let currentPage = viewControllers?[0] else { return }
        guard let prevPage = dataSource?.pageViewController(self, viewControllerBefore: currentPage) else { return }
        
        setViewControllers([prevPage], direction: .forward, animated: animated, completion: completion)
    }
    
    func goToSpecificPage(index: Int, ofViewControllers pages: [UIViewController]) {
        setViewControllers([pages[index]], direction: .forward, animated: true, completion: nil)
    }
}





