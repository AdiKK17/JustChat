const randomString = (len, arr) => {
  len = 16;
  arr = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  var ans = "";
  for (var i = len; i > 0; i--) {
    ans += arr[Math.floor(Math.random() * arr.length)];
  }
  return ans;
};

module.exports.randomString = randomString;
