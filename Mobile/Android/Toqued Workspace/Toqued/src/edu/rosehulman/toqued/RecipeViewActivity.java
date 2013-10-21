package edu.rosehulman.toqued;

import java.util.ArrayList;

import android.app.Activity;
import android.app.Dialog;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

public class RecipeViewActivity extends Activity implements OnClickListener {
	
	private TextView mTitle;
	private TextView mIngredients;
	private TextView mInstructions;
	private ImageView mPhoto;
	private Button mPrev;
	private Button mNext;
	private int mSlideNumber = 0;
	private int mEndNumber;
	private RecipeStructure mRecipe;
	private ArrayList<RecipeStep> mRecipeSteps;  //create an arraylist of recipe steps
	private DatabaseBackend mDbAdapter;
	private ArrayList<FridgeItemStructure> mIngredientList;
	

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_recipe_view);
        
        Intent i = this.getIntent();
        int id = i.getIntExtra(getString(R.string.key_recipe_id), 0);
        //id will be used to pull info in from DB
        
        mDbAdapter = new DatabaseBackend(this);
        mDbAdapter.open();
        
        Log.d(MainMenuActivity.TQD, "Opening recipe with id " + id);

        mRecipe = mDbAdapter.getRecipeById(id);
        
        mRecipeSteps = mDbAdapter.getStepsByRecipeId(id);
        
        mTitle = (TextView) findViewById(R.id.title_text_view);
        mIngredients = (TextView) findViewById(R.id.ingredients_text_view);
        mInstructions = (TextView) findViewById(R.id.instruction_text_view);
        mPhoto = (ImageView) findViewById(R.id.recipe_image_view);
        
        mPhoto.setOnLongClickListener(new View.OnLongClickListener() {
			public boolean onLongClick(View v) {
				Toast.makeText(RecipeViewActivity.this, "Add an image for slide " + mSlideNumber, Toast.LENGTH_SHORT).show();
				return true;
			}
		});
        
        mPrev = (Button) findViewById(R.id.recipe_previous_button);
        mNext = (Button) findViewById(R.id.recipe_next_button);
        
        mPrev.setOnClickListener(this);
        mNext.setOnClickListener(this);
        
//        mRecipe = new RecipeStructure();	//this will be populated from the DB based off the ID
        
//        mRecipeSteps = new ArrayList<RecipeStep>(); //this will be populated from the DB based off the recipe ID
        
        mEndNumber = mRecipeSteps.size()-1; //magic number for now, will be set by the number of rows returned by the db
        
        refreshScreen();
        
        mTitle.setText(getString(R.string.recipe_title_format, mRecipe.getRecipeName()));
    }
    
	@Override
	protected void onDestroy() {
		super.onDestroy();
		mDbAdapter.close();
	}

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_recipe_view, menu);
        return true;
    }
    
    @Override
	public boolean onMenuItemSelected(int featureId, MenuItem item) {
		switch(item.getItemId()){
		case R.id.menu_view_ingredients:
			final Dialog viewIngredientDialog = new Dialog(RecipeViewActivity.this);
			viewIngredientDialog.setContentView(R.layout.recipe_ingredient_view);
			viewIngredientDialog.setTitle(R.string.view_ingredients);
			
			mIngredientList = new ArrayList<FridgeItemStructure>();
			ListView ingredientListView = (ListView) viewIngredientDialog.findViewById(R.id.recipe_ingredient_list_view);
			final ItemAdapter ingredientAdapter = new ItemAdapter(RecipeViewActivity.this, R.layout.list_item, mIngredientList);
			ingredientListView.setAdapter(ingredientAdapter);
			viewIngredientDialog.show();
			return true;
		}
		
		return false;
	}

	public void onClick(View v) {
		switch(v.getId()){
		case R.id.recipe_previous_button: 
				mSlideNumber--;
			break;
			
		case R.id.recipe_next_button: 
				mSlideNumber++;
			break;
		}
		refreshScreen();
		
	}

	private void refreshScreen() {
		//TODO: update the screens based on relevant info
		//ingredients on slide 0 should be all of them...
//		mIngredients.setText(mRecipeSteps.get(mSlideNumber).getIngredients());
		if(mSlideNumber > 0){
			mInstructions.setText(mRecipeSteps.get(mSlideNumber-1).getInstructions());
		}
		
		//set the test on each display properly...
        if(mSlideNumber == 0){
        	mPrev.setClickable(false);
        	mPrev.setTextColor(Color.GRAY);
        	mInstructions.setVisibility(View.GONE);
        	mIngredients.setVisibility(View.GONE);
        	mTitle.setVisibility(View.VISIBLE);
        }else if(mSlideNumber > mEndNumber){
        	mNext.setClickable(false);
        	mNext.setTextColor(Color.GRAY);
        }else{
        	mInstructions.setVisibility(View.VISIBLE);
        	mIngredients.setVisibility(View.GONE);
        	mTitle.setVisibility(View.GONE);
        	mPrev.setClickable(true);
        	mNext.setClickable(true);
        	mPrev.setTextColor(Color.BLACK);
        	mNext.setTextColor(Color.BLACK);
        }
	}
}
