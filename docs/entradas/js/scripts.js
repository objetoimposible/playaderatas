  // Define initial variables.
  var words = [ "posibilidades", "ideas", "búsquedas", "procedimientos", "técnicas", "artes" ,"modos", "juegos"];
  var count = 0;
  
  /*
   * The reason we do the following twice is because setInterval won't
   * initially call the changeWord function until 3 seconds has passed,
   * by doing it once first we make sure that we are changing the word
   * as soon as it starts.
   */
  
  changeWord(); // Call the changeWord function
  setInterval(changeWord, 10000); // Call it every 3 seconds
  
  function changeWord() {
  
      // Define the word to create
      var current_word = words[count];
      console.log(current_word);
  
      // Change the word in the HTML
      $("#rotate_word").html(current_word);
  
      // Get the next word index in the array
      count++;
  
      // If we've reached the end of the word list, go back to the start
      if (count == words.length) { count = 0; }
  }