class Api::SessionController < ApplicationController
  protect_from_forgery :except => :create

  def create
    quiz = Quiz.find_by_token(params[:quiz_token])
    session = Session.create!({ quiz_id: quiz.id, token: get_id_token(quiz.id) })
    render json: flatten_session(session)
  end

  def view
    session = Session.find_by_token(params[:token])
    render json: flatten_session(session)
  end

  def start
    session = Session.find_by_token(params[:token])
    render json: false, :status => :forbidden and return if session.finished

    session.start
    session.tick_start
    render json: true
  end

  def pause
    session = Session.find_by_token(params[:token])
    render json: false, :status => :forbidden and return if session.finished

    session.pause
    session.tick_stop
    render json: true
  end

  def finish
    session = Session.find_by_token(params[:token])

    session.finish
    session.tick_stop
    render json: true
  end

  private

  def flatten_session(session)
    data = session.attributes
    data[:quiz_token] = session.quiz.token
    data[:duration] = 0
    data[:weight] = 0
    data[:score] = 0

    if session.forms
      data[:forms] = session.forms.order_by(:created_at => 'asc').map do |form|
        form_data = flatten_from(form)
        data[:weight]+= form_data[:weight]
        data[:score]+= form_data[:score]
        form_data
      end
    end

    if session.timestamps
      data[:timestamps] = session.timestamps.map do |timestamp|
        timestamp_data = flatten_timestamp(timestamp)
        data[:duration] += timestamp_data[:duration]
        timestamp_data
      end
      logger.info data[:duration]
    end

    data
  end

  def flatten_from(form)
    data = form.attributes
    data[:weight] = form.session.quiz.weight
    data[:score] = form.score

    if form.answers
      data[:answers] = form.answers.map { |a| flatten_answer(a) }
    end

    data
  end

  def flatten_answer(answer)
    data = answer.attributes
    data[:question_id] = answer.question_id.to_s
    data
  end

  def flatten_timestamp(timestamp)
    data = timestamp.attributes
    data[:duration] = timestamp.duration
    data
  end
end
