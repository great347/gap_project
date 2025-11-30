function transform(line) {
  var values = line.split(",");


  if (values[0]==='customer_id') {
    return null;
  }

  var obj = new Object();
  obj.customer_id = parseInt(values[0]);
  obj.full_name = values[1];
  obj.post_code= values[2];
  obj.city= values[3];
  obj.region = values[4];
  obj.last_update_date = values[5];

  var jsonString = JSON.stringify(obj);
  return jsonString
}