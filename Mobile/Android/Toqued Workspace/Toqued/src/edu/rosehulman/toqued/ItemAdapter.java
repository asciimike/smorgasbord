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

public class ItemAdapter extends ArrayAdapter<FridgeItemStructure> {
	private Context mContext;
	private int mResId;

	public ItemAdapter(Context c, int resource, List<FridgeItemStructure> objects) {
		super(c, resource, objects);
		mContext = c;
		mResId = resource;
	}

	public View getView(int pos, View convertView, ViewGroup parent) {
		LinearLayout itemView;
		final FridgeItemStructure currentItem = getItem(pos);

		if (convertView == null) {
			itemView = new LinearLayout(this.getContext());
			LayoutInflater vi = (LayoutInflater) getContext().getSystemService(
					Context.LAYOUT_INFLATER_SERVICE);
			vi.inflate(R.layout.list_item, itemView, true);

		} else {
			itemView = (LinearLayout) convertView;
		}

		if (itemView != null) {
			TextView itemNameView = (TextView) itemView.findViewById(R.id.list_item_text1);
			String name = currentItem.getItemName();
			if(name.length() > 20){
				name = name.substring(0, 19) + "...";
			}
			itemNameView.setText(name);

			TextView quantityView = (TextView) itemView.findViewById(R.id.list_item_text2);
			if(currentItem.getQuantity()==0){
				quantityView.setVisibility(View.GONE);
			}else{
				quantityView.setText("Quantity: " + currentItem.getQuantity());
				quantityView.setVisibility(View.VISIBLE);
			}

			TextView unitView = (TextView) itemView.findViewById(R.id.list_item_text3);
			if(!currentItem.getUnit().equals("")){
				unitView.setText("Unit: " + currentItem.getUnit());
				unitView.setVisibility(View.VISIBLE);
			}else{
				unitView.setVisibility(View.GONE);
			}

			ImageView itemImageView = (ImageView) itemView.findViewById(R.id.list_item_image_view);
			itemImageView.setImageResource(R.drawable.ic_launcher);
			itemImageView.setOnLongClickListener(new View.OnLongClickListener() {
				
				public boolean onLongClick(View v) {
					Toast.makeText(mContext, "Add an image", Toast.LENGTH_SHORT).show();
					return true;
				}
			});
		}

		return itemView;
	}
}
