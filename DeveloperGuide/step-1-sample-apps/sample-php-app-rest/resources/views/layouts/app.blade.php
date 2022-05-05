<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">

		<!-- CSRF Token -->
		<meta name="csrf-token" content="{{ csrf_token() }}">

		<title>{{ config('app.name', 'Contoso NoshNow') }}</title>

		<!-- Scripts -->
		<script src="{{ asset('js/app.js') }}"></script>
		<script src="{{ asset('js/custom.js') }}"></script>

		<!-- Fonts -->
		<link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700&display=swap" rel="stylesheet">

		<!-- Styles -->
		<style>
			/*! normalize.css v8.0.1 | MIT License | github.com/necolas/normalize.css */html{line-height:1.15;-webkit-text-size-adjust:100%}body{margin:0}a{background-color:transparent}[hidden]{display:none}html{font-family:system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica Neue,Arial,Noto Sans,sans-serif,Apple Color Emoji,Segoe UI Emoji,Segoe UI Symbol,Noto Color Emoji;line-height:1.5}*,:after,:before{box-sizing:border-box;border:0 solid #e2e8f0}a{color:inherit;text-decoration:inherit}svg,video{display:block;vertical-align:middle}video{max-width:100%;height:auto}body{font-family: 'Nunito', sans-serif}
		</style>
		<link href="{{ asset('css/normalize.css') }}" rel="stylesheet">
		<link href="{{ asset('css/skeleton.css') }}" rel="stylesheet">
		<link href="{{ asset('css/icomoon.css') }}" rel="stylesheet">
		<link href="{{ asset('css/custom.css') }}" rel="stylesheet">
		<link href="{{ asset('css/app.css') }}" rel="stylesheet">
@stack('styles')
	</head>
	<body class="antialiased">

@if(isset($header))
		<div class="header">
			<a href="{{ route('home') }}">
				<img src="/img/white-gd422548d7_640.png">
				{{ config('app.name', '') }}
			</a>
		</div>
@endif

		<div id="global_cart" class="global-cart">
{!! $global_cart['html'] ?? '' !!}
		</div>

@yield('content')

		<!-- show a little warning message if the data is coming from JSON and not the database -->
		<div class="json-warning {{ $json_warning ?? '' ? '' : 'initially-hidden' }}">Site is unable to pull from database. Using JSON data instead.</div>

@stack('scripts')
	</body>
</html>
