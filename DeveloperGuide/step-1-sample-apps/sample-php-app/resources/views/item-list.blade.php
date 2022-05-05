@extends('layouts.app')
@section('content')

	<h3>Select a meal</h3>

	<div class="center-block item-list">
		<div class="two-thirds column">
			<div class="row">
			@foreach($item as $i)
				<div class="item one-third column">
					<div class="image" style="background-image:url(/img/{{ $i->img }});"></div>
					<div class="name">{{ $i->name }}</div>
					<div class="price"><sup>$</sup>{{ is_numeric($i->price) ? number_format($i->price, 2) : '0.00' }}</div>
					<div class="desc">
						<div class="overflow">{{ $i->desc }}</div>
					</div>
					<button class="add-to-cart button-small button-primary" data-item="{{ $i->id }}">Add</button>
				</div>
			@endforeach
			</div>
		</div>
		<a href="{{ route('category-list') }}" class="button">Back</a>
		<button class="button {{ $global_cart['cart_total'] ? 'button-primary' : '' }} checkout-button" {{ $global_cart['cart_total'] ? '' : 'disabled' }}>Continue</button>
	</div>

@endsection
@push('scripts')
<script>
// to keep the layout and design simple, only show 6 lines of text from the item description
var ellipsis_lines = 6;
$(document).ready( function() {
	ellipsis();

	$('.checkout-button').on('click', function() {
		var url = "{{ route('checkout') }}";
		// fun little trick to allow ctrl-click on a javascript click event just like regular links
		if (event.metaKey || event.ctrlKey) {
			window.open(url,'_blank');
		} else {
			location.href = url;
		}
	});

});
$(window).resize( function() {
	ellipsis();
});

// function to add ellipsis after (N) lines of text
function ellipsis() {
	var lines = ellipsis_lines;
	$('.overflow').each(function( index ) {
		var inner = $(this);
		var outer = inner.parent();
		if (inner.attr('data-text')) {
			var innertext = inner.attr('data-text');
		} else {
			var innertext = inner.text();
		}
		var lineheight = inner.css('line-height');
		var height = (lineheight.replace('px','')-0)*(lines-0);
		outer.css({'height':height});
		inner.attr('data-text',innertext);
		inner.text(innertext);
		while (inner.outerHeight() > height) {
			inner.text(function (index, text) {
				return text.replace(/\W*\s(\S)*$/, '...');
			});
		}
	});
}
</script>
@endpush
