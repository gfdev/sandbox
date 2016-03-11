#!/usr/bin/env perl

use 5.010;
use Data::Dumper 'Dumper';
use Time::HiRes qw(time usleep);

use Glib ':constants';
use Gtk3 -init;
use Gtk3::WebKit;
use HTTP::Soup;

my $quit = 0;
my $url = 'https://www.instagram.com';
#my $url = 'https://www.facebook.com';
#my $url = 'http://ifconfig.me/all';

my $session = Gtk3::WebKit::get_default_session();
my $view = Gtk3::WebKit::WebView->new();

$view->get_settings->set('auto-load-images' => FALSE);
$view->get_settings->set('enable_plugins' => FALSE);
#say $view->get_settings;
#say $view->get_settings->set('auto-load-images' => 0);
#say $view->get_settings->get_user_agent;
#say $view->get_settings->get('user-agent');
#say $view->get_window_features;

my $resources = {};

$session->signal_connect('request-started' => sub {
    my ($session, $message, $socket, $resources) = @_;
    
    say 'URI ', '[', $message->get('method'), ']: ', $message->get_uri->to_string(FALSE);
    #say $message->get('method');
    #say $message->get_address->get_name;
    
    $message->signal_connect('finished' => sub {
        my $status_code = $resources->{status_code} = $message->get('status-code') // 'undef';

        my $headers = $message->get('response-headers');
        $headers->foreach(sub {
            my ($name, $value) = @_;
            
            #say "$name: $value";
        });
        
        my $body = $message->get('response-body');
        
        #say $body;
    });

}, $resources);

#$view->signal_connect('notify::load-status' => sub {# say Dumper \@_;
#    my ($v) = @_;
#    
#    #return unless $v->get_uri;
#    #
#    #say Dumper $v->get_main_frame->get_data_source->is_loading;
#    #
#    #return unless $v->get_load_status eq 'finished';
#    #
#    #say Dumper $v->get_main_frame->get_data_source->get_data;
#    #say Dumper $v->get_main_frame->get_data_source->get_initial_request;
#    #say Dumper $v->get_main_frame->get_data_source->get_initial_request->get_data;
#    
#    #say Dumper $v->get_uri;
#    #say Dumper $v->get_title;
#    #say Dumper $v->get_encoding;
#    #say Dumper $v->get_main_frame;
#    #say Dumper $v->get_main_frame->get_dom_document;
#    #say Dumper $v->get_main_frame->get_dom_document->get_body;
#    #say Dumper $v->get_main_frame->get_dom_document->get('cookie');
#    #say Dumper $v->get_main_frame->get_dom_document->get('head');
#    #say Dumper $v->get_main_frame->get_dom_document->get_body->get_outer_html;
#    
#    #Glib::Idle->add(sub {
#    #    
#    #});
#});

#$view->signal_connect('load-finished' => sub { say 'load-finished'; #say Dumper \@_;
#    my ($webview, $webframe) = @_;
#    
#    #say Dumper $webframe->get_dom_document;
#    #say Dumper $webframe->get_dom_document->get_body->get_outer_html;
#    
#    say Dumper $webview->get_main_frame->get_main_frame->get_data_source->get_data;
#    
#    #Glib::Idle->add(sub {
#    #    say Dumper $webview->get_main_frame->get_dom_document->get_body->get_outer_html;
#    #});
#});

#$view->signal_connect('document-load-finished' => sub { say 'document-load-finished'; #say Dumper \@_;
#    my ($webview, $webframe) = @_;
#    
#    #say Dumper $webview->get_main_frame->get_dom_document->get_body->get_outer_html;
#});

#$view->signal_connect('frame-created' => sub { say 'frame-created'; #say Dumper \@_;
#    my ($webview, $webframe) = @_;
#    
#    #say Dumper $webframe->get_dom_document->get_body->get_outer_html;
#});
#
#$view->signal_connect('notify::load-status' => sub { say 'load-status'; #say Dumper \@_;
#    my ($webview, $webframe) = @_;
#    
#    #say Dumper $webframe->get_dom_document->get_body->get_outer_html;
#});
#$view->signal_connect('load-finished' => sub { say 'load-finished'; #say Dumper \@_;
#    my ($webview, $webframe) = @_;
#    
#    #say Dumper $webframe->get_dom_document->get_body->get_outer_html;
#});

#$view->signal_connect('notify::print-requested' => sub { say 'print-requested'; say Dumper \@_;
#    my ($webview, $webframe) = @_;
#    
#    #say Dumper $webframe->get_dom_document->get_body->get_outer_html;
#});

$view->signal_connect('resource-load-finished' => sub {# say 'resource-load-finished'; #say Dumper \@_;
    my ($webview, $webframe) = @_;
    
    return if $webview->get_load_status ne 'finished';
    
    say 'x' x 100;
    
    my $message  = $webframe->get_network_response->get_message;
    my $document = $webframe->get_dom_document;
    my $window   = $document->get_default_view;
    my $body     = $document->get_body;
    
    #say $webview->get_main_frame->get_data_source->get_data;
    say $body->get_outer_html;
    
    if ($body->get_outer_html =~ m{<a[^>]+>codex_ss</a>}s) {
        $quit = 1;
        say $document->get('cookie');
        return;
    }
    
    if ($body->get_outer_html =~ m{<form[^>]+>.*?<p[^>]+role="alert"[^>]+>[^<]+</p>.*?</form>}s) {
        $quit = 1;
        say $document->get('cookie');
        return;
    }
    
    #<form[^>]+>.*?<p[^>]+role="alert"[^>]+>([^<]+)</p>.*?</form>
    #<a class="_6ssv5" href="/codex_ss/" data-reactid=".0.2.0.1.$profileLink">codex_ss</a>
    
    #say $message->get('uri')->to_string(TRUE);
    #say Dumper $webframe->get_parent;
    #say Dumper $webframe->get_title;
    #say Dumper $webframe->get_uri;
    #say $message->get('method');
    #say $message->get('request-body')->buffer_get_as_bytes;
    #say $message->get('response-body')->buffer_get_as_bytes;
    #say $message->get('response-headers');
    #say $message->get('server-side');
    #say $message->get('status-code');
    #say $message->get_message;
    #say Dumper $body->get_outer_html;
    
    if ($document->get_forms->get_length > 0) {
        my $form = $document->get_forms->item(0);
        my $elements = $form->get_elements;
        
        #say $elements->get_length;
        
        if ($elements->get_length == 3) {
            $webview->execute_script(q|
                (function() {
                    var user = document.forms[0].elements[0]
                        , pass = document.forms[0].elements[1]
                        , button = document.forms[0].elements[2]
                        , te
                    ;
                    
                    if (user.value) return;
                    
                    user.value = '';
                    pass.value = '';
                    
                    te = document.createEvent('TextEvent');
                    te.initTextEvent('textInput', true, true, null, 'codex_1ss');
                    
                    user.dispatchEvent(te);
                    
                    te = document.createEvent('TextEvent');
                    te.initTextEvent('textInput', true, true, null, 'instagram_instagram');
                    pass.dispatchEvent(te);
                    
                    button.click();
                })();
            |);
        } elsif ($elements->get_length == 6) {
            $webview->execute_script(q|
                (function() {
                    var links = document.getElementsByTagName("a");
                    
                    for (var i = 0, l = links.length; i < l; i++) {
                        if (links[i].textContent === 'Log in') {
                            links[i].click();
                            
                            var user = document.forms[0].elements[0]
                                , pass = document.forms[0].elements[1]
                                , button = document.forms[0].elements[2]
                                , te
                            ;
                            
                            if (user.value) return;
                            
                            user.value = '';
                            pass.value = '';
                            
                            te = document.createEvent('TextEvent');
                            te.initTextEvent('textInput', true, true, null, 'codex1_ss');
                            
                            user.dispatchEvent(te);
                            
                            te = document.createEvent('TextEvent');
                            te.initTextEvent('textInput', true, true, null, 'instagram_instagram');
                            pass.dispatchEvent(te);
                            
                            button.click();
                                
                            break;
                        }
                    }
                })();
            |);
        }
    }
});

#$view->signal_connect('web-view-ready' => sub { say 'web-view-ready'; #say Dumper \@_;
#    my ($webview, $webframe) = @_;
#    
#    #say Dumper $webview->get_main_frame->get_dom_document->get_body->get_outer_html;
#});

#$view->load_uri($url);

$view->load_uri($url);
#$view->load_html_string($string, 'text/html', 'UTF-8', 'https://www.instagram.com');
#$view->load_html_string($string, 'https://www.instagram.com');
#$view->load_string($string, NULL, NULL, 'https://www.instagram.com');

my $window = Gtk3::Window->new('toplevel'); $window->set_default_size(320, 480); $window->signal_connect(destroy => sub {  });
my $scrolls = Gtk3::ScrolledWindow->new(); $scrolls->add($view); $window->add($scrolls); $window->show_all();

#say Dumper $view->get_window_features;

#Gtk3::main_iteration while Gtk3::events_pending or $view->get_load_status ne 'finished';
#Gtk3::main_iteration while 1;

#while (Gtk3::events_pending or $view->get_load_status ne 'finished') {
while (1) {
    Gtk3::main_iteration;
    
    last if $quit == 1;
}

say 'Done!';
