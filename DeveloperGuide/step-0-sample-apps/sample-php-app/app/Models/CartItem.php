<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CartItem extends Model
{
	use HasFactory;

	public $timestamps = false;

	protected $fillable = [
		'cart_id',
		'item_id',
		'qty',
	];

	protected $with = [
		'item',
	];

	public function cart()
	{
		return $this->belongsTo(Cart::class, 'cart_id', 'id');
	}

	public function item()
	{
		return $this->hasOne(Item::class, 'id', 'item_id')->orderBy('name');
	}

}
