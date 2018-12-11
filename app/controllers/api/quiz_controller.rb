class Api::QuizController < ApplicationController
  before_action :prepare_markdown

  def list
    render json: Quiz.all.order_by(:id => 'desc')
  end

  def extended
    quiz = Quiz.find_by_token(params[:token])
    render json: flatten_quiz(quiz)
  end

  def extended_by_session
    session = Session.find_by_token(params[:session_token])
    render json: false, :status => :forbidden and return if !session.finished
    render json: flatten_quiz(session.quiz, true)
  end

  private

  def prepare_markdown
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      autolink: true,
      tables: true,
      fenced_code_blocks: true)
  end

  def flatten_quiz(quiz, with_weights = false)
    data = quiz.attributes.except(:id)
    data[:id] = quiz.id.to_s

    if quiz.questions
      data[:questions]= quiz.questions.order_by(order: 'asc').map { |a| flatten_question(a, with_weights) }
    end

    data
  end

  def flatten_question(question, with_weights)
    data = question.attributes.except(:id, :content)
    data[:id] = question.id.to_s
    data[:content] = @markdown.render(question.content)
      data[:weight] = question.weight if with_weights

    if question.options
      data[:options] = question.options.map { |a| flatten_option(question, a, with_weights) }
    end

    data
  end

  def flatten_option(question, option, with_weights)
    data = option.attributes.except(:id, :weight)
    data[:id] = option.id.to_s
    data[:content] = %w(checkbox radio).include?(question.type) ? @markdown.render(option.content) : option.content
    data[:weight] = option.weight if with_weights
    data
  end
end
