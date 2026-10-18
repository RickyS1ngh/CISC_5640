#!/bin/bash

# Start MongoDB shell
mongosh universityDB <<'EOF'

db.students.drop()

db.createCollection("students")

db.students.insertMany([
  {
    student_id: "S10001",
    name: "Alice Johnson",
    major: "Computer Science",
    year: 3,
    courses: [
      { course_id: "CS501", name: "Advanced Databases", grade: "A" },
      { course_id: "CS502", name: "Data Mining", grade: "B+" }
    ],
    activities: ["AI Club", "Robotics Club"]
  },
  {
    student_id: "S10002",
    name: "Bob Smith",
    major: "Information Systems",
    year: 2,
    courses: [
      { course_id: "IS601", name: "Cloud Computing", grade: "A-" },
      { course_id: "IS602", name: "Cybersecurity", grade: "B" }
    ],
    activities: ["Cybersecurity Club"]
  },
  {
    student_id: "S10003",
    name: "Carla Nguyen",
    year: 1,
    courses: [
      { course_id: "CS501", name: "Advanced Databases", grade: "B+" }
    ],
    activities: []
  },
  {
    student_id: "S10004",
    name: "David Lee",
    major: "Data Science",
    year: 4,
    courses: [
      { course_id: "DS701", name: "Machine Learning", grade: "A" },
      { course_id: "DS702", name: "Big Data Systems", grade: "A-" }
    ],
    activities: ["Data Science Club"]
  },
  {
    student_id: "S10005",
    name: "Emily Chen",
    major: "Computer Science",
    year: 3,
    courses: [
      { course_id: "CS502", name: "Data Mining", grade: "A-" },
      { course_id: "CS503", name: "Cloud Databases", grade: "B" }
    ],
    activities: ["AI Club"]
  },
  {
    student_id: "S10006",
    name: "Frank Garcia",
    major: "Software Engineering",
    year: 2,
    courses: [
      { course_id: "SE601", name: "Software Architecture", grade: "B+" }
    ],
    activities: ["Software Club"]
  },
  {
    student_id: "S10007",
    name: "Grace Kim",
    major: "Computer Science",
    year: 1,
    courses: [
      { course_id: "CS501", name: "Advanced Databases", grade: "A" }
    ],
    activities: ["Robotics Club"]
  },
  {
    student_id: "S10008",
    name: "Hannah Patel",
    major: "Information Systems",
    year: 3,
    courses: [],
    activities: []
  },
  {
    student_id: "S10009",
    name: "Ian Walker",
    major: "Data Science",
    year: 4,
    courses: [
      { course_id: "DS701", name: "Machine Learning", grade: "B+" }
    ],
    activities: ["AI Club", "Data Science Club"]
  },
  {
    student_id: "S10010",
    name: "Jessica Alvarez",
    major: "Computer Science",
    year: 2,
    courses: [
      { course_id: "CS503", name: "Cloud Databases", grade: "B" }
    ],
    activities: ["Software Club", "AI Club"]
  }
])

# Queries
db.students.find({ major: "Computer Science" })
db.students.find({ "courses.course_id": "CS502" })
db.students.find({ "courses.grade": "A" }, { _id: 0, name: 1 })
db.students.find({ major: { $exists: false } })
db.students.find({ activities: "AI Club" })

# Indexing
db.students.createIndex({ major: 1 })
db.students.find({ "courses.course_id": "CS502" }).explain("executionStats")
db.students.createIndex({ "courses.course_id": 1 })
db.students.find({ "courses.course_id": "CS502" }).explain("executionStats")

# Average grade 
db.students.aggregate([
  { $unwind: "$courses" },
  {
    $group: {
      _id: {
        course_id: "$courses.course_id",
        course_name: "$courses.name"
      },
      average_grade: {
        $avg: {
          $switch: {
            branches: [
              { case: { $eq: ["$courses.grade", "A"] }, then: 4.0 },
              { case: { $eq: ["$courses.grade", "A-"] }, then: 3.7 },
              { case: { $eq: ["$courses.grade", "B+"] }, then: 3.3 },
              { case: { $eq: ["$courses.grade", "B"] }, then: 3.0 },
              { case: { $eq: ["$courses.grade", "B-"] }, then: 2.7 },
              { case: { $eq: ["$courses.grade", "C+"] }, then: 2.3 },
              { case: { $eq: ["$courses.grade", "C"] }, then: 2.0 },
              { case: { $eq: ["$courses.grade", "C-"] }, then: 1.7 },
              { case: { $eq: ["$courses.grade", "D+"] }, then: 1.3 },
              { case: { $eq: ["$courses.grade", "D"] }, then: 1.0 },
              { case: { $eq: ["$courses.grade", "F"] }, then: 0.0 }
            ],
            default: null
          }
        }
      }
    }
  },
  {
    $project: {
      _id: 0,
      course_id: "$_id.course_id",
      course_name: "$_id.course_name",
      average_grade: { $round: ["$average_grade", 2] }
    }
  },
  { $sort: { course_id: 1 } }
])

# Count students in each major
db.students.aggregate([
  {
    $group: {
      _id: "$major",
      student_count: { $sum: 1 }
    }
  },
  {
    $project: {
      _id: 0,
      major: { $ifNull: ["$_id", "Not specified"] },
      student_count: 1
    }
  },
  { $sort: { major: 1 } }
])

# Add course_count
db.students.updateMany(
  {},
  [
    {
      $set: {
        course_count: {
          $size: { $ifNull: ["$courses", []] }
        }
      }
    }
  ]
)


EOF
