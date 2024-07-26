#! /usr/bin/env python3
import logging
from dotenv import load_dotenv
from flask import Flask, abort, jsonify
from flask_restful import Api, Resource
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.sql import text
from healthcheck import HealthCheck
from broken_flask_client.employees import get_employees
from faker import Faker

load_dotenv()
health = HealthCheck()

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///users.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
api = Api(app, prefix="/api/v2")


@app.route('/', methods=['GET'])
def home():
    return {"message": "Hello, Users!"}


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50))


def insert_example_users():
    fake = Faker()
    if User.query.count() > 0:
        return
    print("Inserting example users...")
    users = [User(id=i, name=fake.name()) for i in range(1, 20)]
    db.session.add_all(users)
    db.session.commit()


with app.app_context():
    db.create_all()
    print("Database tables created.")
    insert_example_users()


class UserResource(Resource):
    def get(self, id):
        """Fetch a user given its identifier"""
        try:
            # Directly incorporating user input into the SQL query
            raw_query_string = f"SELECT * FROM user WHERE id = {id}"
            query = text(raw_query_string)

            # Execute the vulnerable query
            result = db.session.execute(query)
            user = result.fetchall()

            if user:
                user_dict = dict(user)
                return jsonify(user_dict)
            else:
                abort(404)
        except Exception as e:
            print(f"An error occurred: {str(e)}")
            abort(500, description=f"An error occurred: {str(e)}")


class EmployeeResource(Resource):
    def get(self, id):
        """Fetch an employee given its identifier"""
        try:
            return get_employees(id)
        except Exception as e:
            print(f"An error occurred: {str(e)}")
            abort(500, description=f"An error occurred: {str(e)}")


api.add_resource(UserResource, '/users/<string:id>')
api.add_resource(EmployeeResource, '/employees/<string:id>')
app.add_url_rule("/healthcheck", "healthcheck", view_func=lambda: health.run())

if __name__ == '__main__':
    app.run(port=4000)
