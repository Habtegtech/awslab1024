
/*
 * Specification
 *   DynamoDB table with name 'inventory' and primary key ISBN13
 *   Load all records from ../books
 */

/***************************
 DATABASE SECTION
***************************/

resource "aws_dynamodb_table" "habtamu_books" {
  name           = "habtamu_books"         # Unique table name
  billing_mode   = "PAY_PER_REQUEST"        # On-demand billing mode
  hash_key       = "ISBN13"                 # Primary key

  attribute {
    name = "ISBN13"
    type = "S"                              # 'S' for String type
  }

  tags = {
    Name = "HabtamuBooksTable"              # Unique tag for the table
  }
}
/***************************
 LOAD DATA SECTION
***************************/

resource "null_resource" "load_books_data" {
  provisioner "local-exec" {
    command = <<EOT
      for file in ./books/*.json; do
        aws dynamodb put-item --table-name ${aws_dynamodb_table.habtamu_books.name} --item file://$file
      done
    EOT
  }

  depends_on = [aws_dynamodb_table.habtamu_books]
}

