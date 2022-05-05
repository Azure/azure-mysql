$.ajaxSetup({
	headers: {
		'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
	}
});

$(document).ready( function() {
	init_cart();

	$('.category').on('click', function() {
		$('.category').removeClass('selected');
		$(this).addClass('selected');
		$('.select-category').attr('disabled',false).addClass('button-primary');
	});
	$('.select-category').on('click', function() {
		var category = $('.category.selected').attr('data-url');
		var url = "/item-list/" + category;
		location.href=url;
	});

	$('.add-to-cart').on('click', function() {
		var item = $(this).attr('data-item');
		$.ajax({
			method: "POST",
			data: { 'item':item },
			url: '/add-to-cart',
			success: function (result) {
				// console.log(result);
				$('#global_cart').html(result.html);
				$('.cart-block').slideDown(250);
				if (result.cart_total) {
					$('.checkout-button').addClass('button-primary').attr('disabled',false);
				} else {
					$('.checkout-button').removeClass('button-primary').attr('disabled',true);
				}
				init_cart();
			},
			error: function (e) {
				console.log(e);
			}
		});
	});

});

function init_cart() {

	// show cart
	$('.cart-icon:not(.disabled)').unbind('click');
	$('.cart-icon:not(.disabled)').on('click', function() {
		$('.cart-block').slideDown(250);
	});

	// hide cart
	$('.cart-footer .closer').unbind('click');
	$('.cart-footer .closer').on('click', function() {
		$('.cart-block').slideUp(250);
	});

	// update qty of item(s) in cart
	$('.cart-update').unbind('click');
	$('.cart-update').on('click', function() {
		var cart_items = new Object();
		$('.item-qty').each(function() {
			var id = $(this).attr('data-item');
			var qty = $(this).val();
			cart_items[id]= qty;
		});
		$.ajax({
			method: "POST",
			data: { 'cart_items':cart_items },
			url: '/update-cart',
			success: function (result) {
				$('#global_cart').html(result.html);
				if (result.count) {
					$('.checkout-button').addClass('button-primary').attr('disabled',false);
				} else {
					$('.checkout-button').removeClass('button-primary').attr('disabled',true);
				}
				init_cart();
			},
			error: function (e) {
				console.log(e);
			}
		});
	});

}

function set_receipt_text(minutes) {
	// display approximate delivery time, update every minute
	var m = minutes-0;
	if (m > 2) {
		$('#remaining_text').html('Your order will be delivered in approximately <strong>'+m+'</strong>&nbsp;minutes.');
	} else if (m > 0) {
		$('#remaining_text').html('Your order is arriving right now!');
	} else {
		$('#remaining_text').html('Your order has been delivered. We hope you enjoyed your food!');
		return false;
	}
	m--;
	setTimeout(function() {
		set_receipt_text(m);
	}, 60*1000);
}
