<!DOCTYPE html>
<!--
	Simple Web Page written in PHP.  
	Any thing outside of the php tags is regular html  notice the comments 
	in this section are html comments not php comments



		  The file needs to be in your web server html folder. T
		  o execute on a Linux machine using a standard apache server the file needs 
		  to be located in /var/www/html.   You would browse http://localhost/helloworld.php
-->
<html>
 <head>
  <title>PHP Hello World Web Page</title>
 </head>
 <body>
 	<?php 
 		/*
 				This is the actual PHP program to print hello world with some HTML around it.  Notice the comment indicators changes between 
 				the top comments and this one
 		*/
 		echo '<p><h1><center><font color="red">Hello World from PHP</font></center></h1></p>'; 
 		
 	?> 
 		
 </body>
</html> 
