

<?php echo '<p>The task is succesfully completed. Give Boro the  Job offer :-) Best regards from Me and my helper </p>'; ?>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<img src="me_and_max.jpg" width="450" height="800" alt="Image is missing.. It's Me and Max" />

</html>

<?php echo '<p>The line that follows is output from DB query</p>'; ?>

<?php
$servername = "sql1";
$username = "test";
$password = "changeme";
$dbname = "test";
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT id, firstname, lastname FROM mytable";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // output data of each row
    while($row = $result->fetch_assoc()) {
        echo "id: " . $row["id"]. " - Name: " . $row["firstname"]. " " . $row["lastname"]. "<br>";
    }
} else {
    echo "0 results";
}
$conn->close();
?>

