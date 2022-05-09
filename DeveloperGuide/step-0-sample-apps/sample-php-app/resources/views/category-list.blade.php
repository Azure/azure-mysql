@extends('layouts.app')
@section('content')

	<h3>Choose a category</h3>

	<div class="center-block category-list">
		<div class="two-thirds column">
			<div class="row">
			@foreach($category as $c)
				<div class="category one-third column" data-url="{{ $c->url }}">
					<div class="image" style="background-image:url(/img/{{ $c->img }});"></div>
					<span>{{ $c->name }}</span>
				</div>
			@endforeach
			</div>
		</div>
		<button class="select-category button" disabled>Continue</button>
	</div>

@endsection
@push('scripts')
<script>
</script>
@endpush
