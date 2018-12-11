class Api::FormController < ApplicationController
  protect_from_forgery :except => [:create, :update]

  def create
    session = Session.find_by_token(params[:session_token])
    render json: false, :status => :forbidden and return unless session.joinable?

    form = Form.create!(
      session_id: session.id,
      token: get_id_token(session.id),
      identity: params[:identity]
    )

    render json: flatten_form(form)
  end

  def update
    form = Form.find_by_token(params[:token])
    render json: false, :status => :forbidden and return unless form.session.writable?

    params[:answers].each do |item|
      instance = form.answers.find_or_create_by(question_id: item[:question_id])
      instance.values = item[:values]
      instance.recalculate
      instance.save
    end

    form.recalculate
    form.save
    render json: flatten_form(form)
  end

  def view
    form = Form.find_by_token(params[:token])
    render json: flatten_form(form)
  end

  private

  def flatten_form(form)
    data = form.attributes
    data[:session_token] = form.session.token

    if form.answers
      data[:answers] = form.answers.map { |a| flatten_answer(a) }
      data[:weight] = form.session.quiz.weight
      data[:score] = form.score
    else
      data[:answers] = []
      data[:weight] = 0
      data[:score] = 0
    end

    data
  end

  def flatten_answer(answer)
    data = answer.attributes
    data[:question_id] = answer.question_id.to_s
    data
  end
end
