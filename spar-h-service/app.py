"""
SPAR-H 人因可靠性分析微服务

核电厂人因数据库系统的 SPAR-H 计算服务端
基于 NUREG/CR-6883 标准实现
"""

from flask import Flask
from flask_cors import CORS
from routes import spar_h_bp


def create_app():
    app = Flask(__name__)
    CORS(app)
    app.register_blueprint(spar_h_bp)
    return app


app = create_app()


@app.route("/health", methods=["GET"])
def health_check():
    return {"status": "ok", "service": "spar-h-engine"}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
