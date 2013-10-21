package edu.rosehulman.toqued;

import java.util.ArrayList;
import java.util.Random;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources;
import android.database.Cursor;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
import android.widget.Toast;
/*
 * Icons from http://www.iconarchive.com/show/desktop-buffet-icons-by-aha-soft/Steak-icon.html (meal), http://www.iconarchive.com/show/cristal-intense-icons-by-tatice/Help-icon.html (random button)
 */
public class StoveMenuActivity extends Activity implements OnClickListener {

	private ImageButton mMealButton;
	private ImageButton mItemButton;
	private ImageButton mRandomButton;
	
	private DatabaseBackend mDbAdapter;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_stove);
        
        //Link buttons up and add listeners
        mMealButton = (ImageButton) findViewById(R.id.stove_menu_meal_button);
        mItemButton = (ImageButton) findViewById(R.id.stove_menu_item_button);
        mRandomButton = (ImageButton) findViewById(R.id.stove_menu_random_button);
        
        mMealButton.setOnClickListener(this);
        mItemButton.setOnClickListener(this);
        mRandomButton.setOnClickListener(this);
        
        mDbAdapter = new DatabaseBackend(this);
        mDbAdapter.open();
        
    }

	@Override
	protected void onDestroy() {
		super.onDestroy();
		mDbAdapter.close();
	}

//    @Override
//    public boolean onCreateOptionsMenu(Menu menu) {
//        getMenuInflater().inflate(R.menu.activity_stove, menu);
//        return true;
//    }

	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.stove_menu_meal_button:
			//Create dialogs for the meal button
			AlertDialog.Builder mealDialog = new AlertDialog.Builder(this);
			mealDialog.setTitle(R.string.stove_menu_meal_selection);
			mealDialog.setItems(R.array.meal_array, new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
					Resources r = getResources();
					String[] meals = r.getStringArray(R.array.meal_array);
					
					//Launch intent for the recipe list (that will deal with populating the list according to the chosen meal)
					Intent mealIntent = new Intent(StoveMenuActivity.this, RecipeBookViewActivity.class);
					mealIntent.putExtra(getString(R.string.KEY_MEAL_SELECTION), meals[which]);	//add the extra so it knows what meal it is
					StoveMenuActivity.this.startActivity(mealIntent);
					dialog.dismiss();
				}
			});
			//Cancel button!
			mealDialog.setNeutralButton(R.string.cancel, new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
					dialog.dismiss();
				}
			});
			mealDialog.show();
			break;
			
		case R.id.stove_menu_item_button:
			AlertDialog.Builder itemDialog = new AlertDialog.Builder(this);
			itemDialog.setTitle(R.string.stove_menu_meal_item_select);
			itemDialog.setInverseBackgroundForced(true);
			itemDialog.setItems(R.array.item_array, new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
					Resources r = getResources();
					String[] items = r.getStringArray(R.array.meal_array);
					dialog.dismiss();
					
					//TODO launch dialog pickers for these...  or get rid of this functionality if it's a pain
					switch (which) {
					case 0:	//Ingredient
						
						break;
						
					case 1:	//Number of servings
						
						break;
						
					case 2:	//Prep time
	
						break;
					}
				}
			});
			
			itemDialog.setNeutralButton(R.string.cancel, new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
					dialog.dismiss();
				}
			});
			itemDialog.show();
			break;
			
		case R.id.stove_menu_random_button:
			
			//Creative way to find the list of recipe ID's currently available, then add them to a list, select a random item of the list, and use that ID as the key for the recipe
			Cursor c = mDbAdapter.getRecipeIds();
			ArrayList<Integer> idList = new ArrayList<Integer>();
			if(c != null){
				c.moveToFirst();
				if(c.getCount() != 0){
					do {
						idList.add(c.getInt(0));
					} while (c.moveToNext());
				}
			}
			
			if(idList.size()==0){
				Toast.makeText(this, "No recipes available", Toast.LENGTH_SHORT).show();
				return;
			}
			
			int rand = new Random().nextInt(idList.size());
			
			Intent randomIntent = new Intent(StoveMenuActivity.this, RecipeViewActivity.class);
			randomIntent.putExtra(getString(R.string.key_recipe_id), idList.get(rand));
			StoveMenuActivity.this.startActivity(randomIntent);
			break;
			
		default:
			
			break;
		}
		
	}
    
}
