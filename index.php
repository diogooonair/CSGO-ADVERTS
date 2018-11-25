<?php
                    error_reporting(E_ALL);
                    ini_set('display_errors', 1);
		
		
					
					//Variables
                    $username = "user";
                    $password = "pass";
                    $hostname = "ip"; 
                    //$ip_user = $_SERVER['HTTP_CLIENT_IP'] ;
                    $db_name = "database";

                    //connect to database
                    $connection = mysqli_connect($hostname, $username, $password);
					if(!$connection){
						die("Database selection failed: " . mysqli_error());
					}

                    //Select database
                    $db_select = mysqli_select_db($connection, $db_name) or die("Cannot find the database");
					if (!$db_select){
						die("Db selection failed: " . mysqli_error($connection));
					}
					
					
					function ipCheck() {
                        if (getenv('HTTP_CLIENT_IP')) {
                            $ip = getenv('HTTP_CLIENT_IP');
                            }
                        elseif (getenv('HTTP_X_FORWARDED_FOR')) {
                            $ip = getenv('HTTP_X_FORWARDED_FOR');
                            }
                        elseif (getenv('HTTP_X_FORWARDED')) {
                            $ip = getenv('HTTP_X_FORWARDED');
                            }
                        elseif (getenv('HTTP_FORWARDED_FOR')) {
                            $ip = getenv('HTTP_FORWARDED_FOR');
                            }
                        elseif (getenv('HTTP_FORWARDED')) {
                            $ip = getenv('HTTP_FORWARDED');
                            }
                        else {
                            $ip = $_SERVER['REMOTE_ADDR'];
                            }
                        return $ip;
                        }
						
					$ipr = ipCheck();

                    //execute the SQL INSERT query
                    mysqli_query($connection, "INSERT INTO iplogs(ip) VALUES ('$ipr')");

                    //close the connection
                    mysqli_close($connection);

					
					
					//PUT THERE YOU RE ADSENSE CODE(DON T KNOW WHAT S OR WANT HELP WITH IT CONTACT DIOGOONAIR www.steamcommunity.com/id/diogo218dv
