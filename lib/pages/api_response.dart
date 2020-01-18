class ApiResponse<T> {
  bool ok;
  String msg;
  T result;

  ApiResponse.ok(this.result, {String msg}) {
    ok = true;
    if (msg != null) {
      this.msg = msg;
    }
  }

  ApiResponse.error(this.msg) {
    ok = false;
  }

  static void setMsg(String msg) {
    msg = msg;
  }
}
