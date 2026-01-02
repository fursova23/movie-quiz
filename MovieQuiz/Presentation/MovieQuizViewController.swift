import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswersCount: Int = 0
    private let questions: [QuizQuestion] = QuizQuestion.mock
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        showCurrentQuestion()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        setButtonsEnabled(false)
        handleAnswer(true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        setButtonsEnabled(false)
        handleAnswer(false)
    }
    
    // MARK: - Game Logic
    
    private func handleAnswer(_ answer: Bool) {
        let isCorrect = checkCorrectAnswer(answer)
        showAnswerResult(isCorrect: isCorrect)
    }
    
    private func checkCorrectAnswer(_ answer: Bool) -> Bool {
        questions[currentQuestionIndex].correctAnswer == answer
    }
    
    private func showNextQuestionOrResults() {
        resetImageBorder()
        
        if currentQuestionIndex == questions.count - 1 {
            showResults()
        } else {
            currentQuestionIndex += 1
            showCurrentQuestion()
        }
    }
    
    // MARK: - UI Updates
    
    private func showCurrentQuestion() {
        let question = questions[currentQuestionIndex]
        let viewModel = convert(model: question)
        show(viewModel)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswersCount += 1
        }
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect
        ? UIColor.ypGreen.cgColor
        : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
            self.setButtonsEnabled(true)
        }
    }
    
    
    private func show(_ step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showResults() {
        let text = "Ваш результат \(correctAnswersCount)/\(questions.count)"
        
        let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть еще раз"
        )
        
        let alert = UIAlertController(
            title: viewModel.title,
            message: viewModel.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: viewModel.buttonText, style: .default) { _ in
            self.restartGame()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    // MARK: - Helpers
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        resetImageBorder()
        showCurrentQuestion()
    }
    
    private func setupImageView() {
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
    }
    
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
