#!/usr/bin/python

import base64
import flask
import jinja2
import mysql.connector
import os

app = flask.Flask(__name__)
scripts_dir = os.getenv("SCRIPTS_DIR", ".")


with open(os.path.join(scripts_dir, "index.j2.html")) as fd:
    index_template = jinja2.Template(fd.read())


class Results:
    def __init__(self, tag: str):
        self.tag = tag
        self.db = self.connect()

    def connect(self):
        return mysql.connector.connect(
            user="root",
            password=os.environ["MARIADB_ROOT_PASSWORD"],
            host=f"mariadb-{self.tag}",
            database="results",
        )

    def state(self):
        cur = self.db.cursor(dictionary=True)
        cur.execute("select state from state where tag = %s", (self.tag,))
        return next(cur)["state"]

    def results(self):
        cur = self.db.cursor(dictionary=True)
        cur.execute("select tag, name, content from files where tag = %s", (self.tag,))
        for res in cur:
            yield res


@app.route("/assets/<filename>")
def assets(filename):
    return flask.send_from_directory(scripts_dir, filename)


@app.route("/")
def index():
    return index_template.render()


@app.route("/api/state")
def state_all():
    state = {}

    for tag in ['local', 'pv']:
        try:
            db = Results(tag)
            state[tag] = db.state()
        except mysql.connector.errors.Error:
            state[tag] = 'unknown'

    return state


@app.route("/api/state/<tag>")
def state_tagged(tag):
    db = Results(tag)
    return {tag: db.state()}


@app.route("/api/results/<tag>")
def results(tag):
    db = Results(tag)
    data = []

    for res in db.results():
        data.append(
            {
                "tag": tag,
                "name": res["name"],
                "content": base64.b64decode(res["content"]).decode(),
            }
        )

    return data
