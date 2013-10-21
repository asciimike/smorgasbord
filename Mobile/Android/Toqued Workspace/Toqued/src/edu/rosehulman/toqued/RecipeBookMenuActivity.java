package edu.rosehulman.toqued;

import android.os.Bundle;
import android.app.Activity;
import android.view.Menu;

public class RecipeBookMenuActivity extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_recipe_book);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_recipe_book, menu);
        return true;
    }
}
