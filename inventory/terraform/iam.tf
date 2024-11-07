
/*
 * Specicication:
 *  Inveotry Server user
 *      Access to read from the DynamoDB Table
 *      Access Keys & Secret
 */

/***************************
 POLICY FOR USER
***************************/

resource "aws_iam_policy" "inventory_server" {
  name        = "inventory-server"
  path        = "/"
  description = "Policy to Read Books Table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Resource = [aws_dynamodb_table.books.arn]
      }
    ]
  })
}

/***************************
 INVENTORY USER SECTION
***************************/

resource "aws_iam_user" "inventory_server" {
  name = "InventoryServer"

  tags = {
    Name = "InventoryServer"
  }
}

resource "aws_iam_user_policy_attachment" "attach_inventory_server" {
  user       = aws_iam_user.inventory_server.name
  policy_arn = aws_iam_policy.inventory_server.arn
}
/********************************
 INVENTORY ACCESS KEYS SECTION
********************************/

