package edu.rosehulman.toqued;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

public class RecipeAdapter extends ArrayAdapter<RecipeStructure> {
	private Context mContext;
	private int mResId;

	public RecipeAdapter(Context c, int resource, List<RecipeStructure> objects) {
		super(c, resource, objects);
		mContext = c;
		mResId = resource;
	}

	public View getView(int pos, View convertView, ViewGroup parent) {
		LinearLayout recipeView;
		final RecipeStructure currentItem = getItem(pos);

		if (convertView == null) {
			recipeView = new LinearLayout(this.getContext());
			LayoutInflater vi = (LayoutInflater) getContext().getSystemService(
					Context.LAYOUT_INFLATER_SERVICE);
			vi.inflate(R.layout.list_item, recipeView, true);

		} else {
			recipeView = (LinearLayout) convertView;
		}

		if (recipeView != null) {
			TextView recipeNameView = (TextView) recipeView.findViewById(R.id.list_item_text1);
			String name = currentItem.getRecipeName();
			if(name.length() > 20){
				name = name.substring(0, 19) + "...";
			}
			recipeNameView.setText(name);

			
			TextView prepTimeView = (TextView) recipeView.findViewById(R.id.list_item_text2);
			
			String unit;
			if(currentItem.getPrepTime() == 1){
				unit = currentItem.getPrepUnit();
			}else{
				unit = currentItem.getPrepUnit() + "s";
			}
			
			prepTimeView.setText("Prep time: " + currentItem.getPrepTime() + " " + unit);

			TextView servingsView = (TextView) recipeView.findViewById(R.id.list_item_text3);
			servingsView.setText("Serves: " + currentItem.getServings());

			ImageView recipeImageView = (ImageView) recipeView.findViewById(R.id.list_item_image_view);
			recipeImageView.setImageResource(R.drawable.ic_launcher);
			recipeImageView.setOnLongClickListener(new View.OnLongClickListener() {
				
				public boolean onLongClick(View v) {
					Toast.makeText(mContext, "Add an image", Toast.LENGTH_SHORT).show();
					return true;
				}
			});
		
		}

		return recipeView;
	}
}
