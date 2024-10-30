

resource "aws_s3_bucket" "my_bucket" {

 	 bucket = "habtamu-bucket-0911108476"  
	
	tags = {
		Name = "habtamu-bucket"			# A name tag for my bucket
		Project = "Aws Bookshop Project"	# A name tag for the project
		
}
 } 
                  


  

   


