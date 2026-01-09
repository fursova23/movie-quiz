import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswersCount: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter = AlertPresenter()
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        statisticService = StatisticService()
        
        setupImageView()
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQustion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async{ [weak self] in
            self?.show(viewModel)
        }
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
    
    private func handleAnswer(_ userAnswer: Bool) {
        guard let currentQuestion else { return }
        let isCorrect = checkCorrectAnswer(currentQuestion, userAnswer)
        showAnswerResult(isCorrect)
    }
    
    private func checkCorrectAnswer(_ currentQuestion: QuizQuestion, _ userAnswer: Bool) -> Bool {
        return currentQuestion.correctAnswer == userAnswer
    }
    
    private func showNextQuestionOrResults() {
        resetImageBorder()
        
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswersCount, total: questionsAmount)
            let viewModel = buildResultsViewModel()
            showResults(viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - UI Updates
   
    private func showAnswerResult(_ isCorrect: Bool) {
        if isCorrect {
            correctAnswersCount += 1
        }
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect
            ? UIColor.ypGreen.cgColor
            : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
            self.setButtonsEnabled(true)
        }
    }
    
    private func show(_ step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showResults(_ viewModel: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: viewModel.title,
            message: viewModel.text,
            buttonText: viewModel.buttonText) { [weak self] in
                guard let self else { return }
                self.restartGame()
            }
       
        alertPresenter.show(in: self, model: alertModel)
    }
    
    // MARK: - Helpers
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        resetImageBorder()
        questionFactory?.requestNextQuestion()
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
    
    private func buildResultsViewModel() -> QuizResultsViewModel {
        var message: String
        if let statisticService {
            let bestGame = statisticService.bestGame
            message = """
                Ваш результат \(correctAnswersCount)/\(questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
        } else {
            message = correctAnswersCount == questionsAmount
                ? "Поздравляем, вы ответили на \(correctAnswersCount) из \(questionsAmount)!"
                : "Вы ответили на \(correctAnswersCount) из \(questionsAmount), попробуйте ещё раз!"
        }

        return QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: message,
            buttonText: "Сыграть еще раз"
        )
    }
    
}
