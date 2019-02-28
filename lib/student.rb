require 'pry'
class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    student = self.new
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  def self.all
    q = <<-SQL
    SELECT * FROM students
    SQL
    all = DB[:conn].execute(q)
    # binding.pry
    all.map { |stud| self.new_from_db(stud) }
  end

  def self.find_by_name(name)
    q = <<-SQL
    SELECT * FROM students
    WHERE name = ?
    LIMIT 1
    SQL
    self.new_from_db(DB[:conn].execute(q,name).flatten)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end

  def self.all_students_in_grade_9
    q = <<-SQL
    SELECT COUNT(name) FROM students
    WHERE grade = 9
    SQL
    DB[:conn].execute(q).flatten
  end

  def self.students_below_12th_grade
    q = <<-SQL
    SELECT * FROM students
    WHERE grade < 12
    SQL
    result = DB[:conn].execute(q)
    result.map { |stud| new_from_db(stud) }
  end

  def self.first_X_students_in_grade_10(limit)
    q = <<-SQL
    SELECT * FROM students
    WHERE grade = 10
    LIMIT ?
    SQL
    DB[:conn].execute(q,limit)
  end

  def self.first_student_in_grade_10
    q = <<-SQL
    SELECT * FROM students
    WHERE grade = 10
    LIMIT 1
    SQL
    DB[:conn].execute(q).map do |stud|
      new_from_db(stud)
    end.first
  end

  def self.all_students_in_grade_X(grade)
    q = <<-SQL
    SELECT * FROM students
    WHERE grade = ?
    SQL
    result = DB[:conn].execute(q,grade)
    result.map { |stud| new_from_db(stud) }
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
