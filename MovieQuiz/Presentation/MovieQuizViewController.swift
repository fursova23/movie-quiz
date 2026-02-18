import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        setupImageView()
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        setButtonsEnabled(false)
        presenter.noButtonClicked(sender)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        setButtonsEnabled(false)
        presenter.yesButtonClicked(sender)
    }
  
    // MARK: - UI Updates
    
    func show(quiz: QuizStepViewModel) {
        resetImageBorder()
        setButtonsEnabled(true)
        imageView.image = UIImage(data: quiz.image)
        textLabel.text = quiz.question
        counterLabel.text = quiz.questionNumber
    }
    
    func showResults(quiz: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: quiz.title,
            message: quiz.text,
            buttonText: quiz.buttonText) { [weak self] in
                guard let self else { return }
                presenter.restartGame()
                resetImageBorder()
            }
       
        alertPresenter.show(in: self, model: alertModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer
            ? UIColor.ypGreen.cgColor
            : UIColor.ypRed.cgColor
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self else { return }
                self.presenter.restartGame()
            }
       
        alertPresenter.show(in: self, model: alertModel)
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func setupImageView() {
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
    }
    
    // MARK: - Private Functions
    
    private func resetImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        let buttons = [yesButton, noButton]
        buttons.forEach {
            $0?.isEnabled = isEnabled
            $0?.alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
}
