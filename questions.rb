require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_reader :id, :fname, :lname

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "#{self} already in the database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users(fname, lname)
      VALUES
        (?,?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in databse " unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname=?, lname=?
      WHERE
        id = ?
    SQL
  end

  def self.find_by_id(id)
    person = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    p person
    User.new(person.first)
  end

  def self.find_by_name(fname, lname)
    people = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    User.new(people.first)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

end
# CREATE TABLE questions (
#   id INTEGER PRIMARY KEY,
#   title TEXT NOT NULL,
#   body TEXT NOT NULL,
#   users_id INTEGER NOT NULL,
#
#   FOREIGN KEY (users_id) REFERENCES users(id)
class Question
  attr_reader :id, :title

  def self.all
    question_all = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    question_all.map{|data| Question.new(data)}
  end

  def self.find_by_title(title)
    quest = QuestionsDatabase.instance.execute(<<-SQL, title)
      SELECT
        *
      FROM
        questions
      WHERE
        title = ?
    SQL
    quest.map{|q| Question.new(q)}
  end

  def self.find_by_id(id)
    quest = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    Question.new(quest.first)

  end

  def self.find_by_author(fname,lname)
    authorid = User.find_by_name(fname, lname).id
    questions = QuestionsDatabase.instance.execute(<<-SQL, authorid)
    SELECT
    *
    FROM
    questions
    WHERE
    users_id=?

    SQL

    questions.map{|q| Question.new(q)}
  end

  def self.find_by_author_id(author_id)
    quest = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    Question.new(quest.first)
  end

  def initialize(options)
    @title=options['title']
    @body=options['body']
    @users_id=options['users_id']
    @id=options['id']

  end

  def create
    raise "#{self} already in the database" if @id
    QuestionsDatabase.instance.execute(<<-SQL , @title, @body, @users_id)
      INSERT INTO
        questions(title, body, users_id)
      values
      (?,?,?)
    SQL
    @id=QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @users_id, @id)
      UPDATE
        questions
      SET
      title = ?,body = ?,users_id = ?
      WHERE
        id = ?
    SQL
  end

end
# CREATE TABLE question_follows (
#   id INTEGER PRIMARY KEY,
#   users_id INTEGER NOT NULL,
#   questions_id INTEGER NOT NULL,
class QuestionFollows
  def self.all
    question_all = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    question_all.map{|data| QuestionFollows.new(data)}
  end
  def self.find_by_id(id)
    quest = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    QuestionFollows.new(quest.first)

  end
  def initialize(options)
    @users_id=options['users_id']
    @questions_id=options['questions_id']
    @id=options['id']
  end
  def create
    raise "#{self} already in database" if @id
    PlayDBConnection.instance.execute(<<-SQL, @users_id, @questions_id)
      INSERT INTO
        question_follows (users_id, questions_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @users_id, @questions_id, @id)
      UPDATE
        question_follows
      SET
      users_id = ?, questions_id = ?
      WHERE
        id = ?
    SQL
  end

end

class Reply
  # CREATE TABLE replies (
  #   id INTEGER PRIMARY KEY,
  #   parent_id INTEGER,
  #   users_id INTEGER NOT NULL,
  #   questions_id INTEGER NOT NULL,
  #   body TEXT NOT NULL,
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @parent_id = options['parent_id']
    @users_id = options['users_id']
    @questions_id = options['questions_id']
    @body = options['body']
  end

  def create
    raise "#{self} already in the database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @parent_id, @users_id, @questions_id, @body)
      INSERT INTO
        replies(parent_id, users_id, questions_id, body)
      VALUES
        (?,?,?,?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in databse " unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @parent_id, @users_id, @questions_id, @body, @id)
      UPDATE
        replies
      SET
        parent_id=?, users_id=?, questions_id=?, body=?
      WHERE
        id = ?
    SQL
  end

  def self.find_by_id(id)
    answer = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    # p person
    Reply.new(answer.first)

  end

  def self.find_by_user_id(user_id)
    answers = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    answers.map {|answer| Reply.new(answer)}
  end

  def self.find_by_question_id(question_id)
    answers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    answers.map {|answer| Reply.new(answer)}
  end

  def author
    User.find_by_id(@users_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_id)
  end

  def child_replies

    children = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    children.map{|child| Reply.new(child)}
  end

end

class QuestionLikes

end
