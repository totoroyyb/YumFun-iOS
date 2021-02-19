# View Design Guidance



1. **Login Screen**

   - login via google, firebase.

     

2. **Home Screen**

   - After login, on the home screen, display recommended recipes with table view or collection view. 

   - Support searching feature. If keyword based searching is too much work, we can start with recipe category filters for searching (users tap on a predefined category, such as bakery, and the app should display all the bakery recipes, possibly sorted by popularity).

   - **Each cell** (a recipe) should display the category of the recipe, the author, number of thumbs-ups,  supports thumbs up, collecting, and comments (comments are not necessary). The top $n$ recipes with the most thumbs-ups will be recommended. 

   - A button for navigating to **"My kitchen"**. 

     

3. **"My kitchen" Screen**

   - A user has three groups of recipes, private, published, and collected. A tableview or collection view for displaying a these recipes. Clicking on a recipe to navigate to the **"Recipe Detail"** view. 

   - An add button for navigating to **"Add recipe"** screen

     

4. **Recipe Detail View**

   - Private recipes
     - Buttons for editing, deleting, and publish

   - Published recipes
     - A button for deleting. Deleted published recipes should **not** be visible to other users, including those who have colleted the recipe.
     - Display the amount of thumbs-ups
     - If possible, we can also support turning to private recipe. This is tricker since we need to decide whether other users who have collected this recipe previously can still view the recipe or not. **Not necessary**.
   - Collected Recipes
     - A button for deleting. Deleting colleted recipes should not cause the recipe to be deleted in the database (since it's created by other users).
     - Display the amount of thumbs-ups
     - Users should **not** be able to collect their own recipes
   - All private, published, and collected recipes should display an eye-catching "cook now" button for navigating to cooking mode.

   

5. **"Add recipe" Screen**

   - A title and a overall description

   - A bunch of categories to be selected from
   - An add button to add steps
     - A step consists of a description, an ingredient list, and a time.
     - An ingredient consists of the ingredient name and amount.

   - An button to select whether to publish the recipe

   - Some UI for uploading images (not necessary)



6. **Cooking mode**
   - A Check box for each step. Checking the step to dismiss it from the screen.
   - Set timer for a step, using the time element of a step.

