<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Item extends Model
{
	use HasFactory;

	public $timestamps = false;

	protected $fillable = [
		'category_id',
		'name',
		'img',
		'price',
		'cooktime',
		'desc',
	];

	public function category()
	{
		return $this->belongsTo(Category::class, 'category_id', 'id');
	}

}
