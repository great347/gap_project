function transform(line) {
  var values = line.split(",");


  if (values[0]==='Transaction_id') {
    return null;
  }

  var obj = new Object();
  obj.Transaction_id = parseInt(values[0]);
  obj.consumer_id = parseInt(values[1]);
  obj.Transaction_created_at= values[2];
  obj.Transaction_update_date= values[3];
  obj.Transaction_type = values[4];
  obj.Transaction_payment_value = parseInt(values[5]);

  var jsonString = JSON.stringify(obj);
  return jsonString
}