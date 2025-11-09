
from flask import Flask, render_template, request, redirect, url_for, session, g, flash
import sqlite3
import os
import sys
from werkzeug.security import generate_password_hash, check_password_hash

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, 'auth.db')

app = Flask(__name__)
app.secret_key = os.environ.get('FLASK_SECRET', 'dev-secret-change-me')

# --- Database helpers ---

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(DB_PATH)
        db.row_factory = sqlite3.Row
    return db


def query_db(query, args=(), one=False):
    cur = get_db().execute(query, args)
    rv = cur.fetchall()
    cur.close()
    return (rv[0] if rv else None) if one else rv


def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute(
        '''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL
        )
        '''
    )
    conn.commit()
    conn.close()
    print('Initialized database at', DB_PATH)


@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()


# --- Auth helpers ---

def get_current_user():
    uid = session.get('user_id')
    if not uid:
        return None
    return query_db('SELECT id, username FROM users WHERE id = ?', (uid,), one=True)


# --- Routes ---

@app.route('/')
def index():
    user = get_current_user()
    if user:
        return redirect(url_for('home'))
    return redirect(url_for('login'))


@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')
        if not username or not password:
            flash('Username and password are required', 'error')
            return redirect(url_for('register'))
        password_hash = generate_password_hash(password)
        try:
            db = get_db()
            db.execute('INSERT INTO users (username, password_hash) VALUES (?, ?)', (username, password_hash))
            db.commit()
            flash('Account created. Please log in.', 'success')
            return redirect(url_for('login'))
        except sqlite3.IntegrityError:
            flash('Username already taken', 'error')
            return redirect(url_for('register'))
    return render_template('register.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')
        if not username or not password:
            flash('Username and password are required', 'error')
            return redirect(url_for('login'))
        user = query_db('SELECT id, username, password_hash FROM users WHERE username = ?', (username,), one=True)
        if user and check_password_hash(user['password_hash'], password):
            session.clear()
            session['user_id'] = user['id']
            session['username'] = user['username']
            flash('Logged in successfully', 'success')
            return redirect(url_for('home'))
        flash('Invalid credentials', 'error')
        return redirect(url_for('login'))
    return render_template('login.html')


@app.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out', 'info')
    return redirect(url_for('login'))


@app.route('/home')
def home():
    user = get_current_user()
    if not user:
        return redirect(url_for('login'))
    return render_template('home.html', username=user['username'])


if __name__ == '__main__':
    # Support a simple CLI: `python app.py initdb` to initialize DB
    if len(sys.argv) > 1 and sys.argv[1] == 'initdb':
        init_db()
        sys.exit(0)
    # Run development server
    # By default listen on localhost:5000
    app.run(debug=True)

