import 'dart:async';
import 'dart:async' show Future;

import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_spinner/material_spinner.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

import 'src/preview_component.dart';

class FormData {
  String url;
  String descLength;

  FormData(this.url, this.descLength);
}

class MetaData {
  String title;
  String siteName;
  String description;
  Uri url;
  Uri imageUrl;

  MetaData({this.title, this.siteName, this.description, this.url, this.imageUrl});

  void clean() {
    title = '';
    siteName = '';
    description = '';
    url = null;
    imageUrl = null;
  }

  @override
  String toString() {
    return '$title $siteName $url $imageUrl $description';
  }
}

@Component(
  selector: 'og-card-generator',
  templateUrl: 'app_component.html',
  directives: [
    coreDirectives,
    formDirectives,
    PreviewComponent,
    MaterialButtonComponent,
    materialInputDirectives,
    MaterialSpinnerComponent,
  ],
  styleUrls: ['app_component.css'],
)
class AppComponent {
  FormData model = FormData('', 140.toString());
  String result;
  String errors;
  MetaData metaData = MetaData();
  bool loading = false;
  String ogCss = '';
  String previewWidth = 800.toString();
  String previewHeight = 300.toString();

  AppComponent() {
    final url = '/ogcard.css';
    http.get(url).then((res) => res.body).then((body) {
      ogCss = body.replaceAll("\n", "");
    });
  }

  void reset() {
    result = 'will be shown here';
    errors = '';
    metaData = MetaData();
  }

  void onEnter() => getBody(model.url);

  String convertToResult(MetaData md) => '''
<div class="ogcard">
<a href="${md.url}" class="ogcard--anchor" title="${md.url}">
<strong class="ogcard--strong">${md.title}</strong>
<br>
<em class="ogcard--em">
${md.description}
</em>
<span class="ogcard--site">${md.siteName}</span>
</a>
<a href="${md.url}" class="ogcard--image" style="background-image: url(${md.imageUrl});"></a>
</div>
'''
      .replaceAll("\n", "");

  Future<void> getBody(String url) async {
    loading = true;
    reset();
    try {
      result = await requestCrossDomain(url);
    } catch (e) {
      errors = e.toString();
    }
    loading = false;
  }

  Future<String> requestCrossDomain(String url) async {
    final corsGateway = 'https://cors-anywhere.herokuapp.com/' + url;
    final jsonString = await http.get(corsGateway);
    final body = jsonString.body;
    final doc = parser.parse(body);

    doc.getElementsByTagName('meta').forEach((meta) {
      final attr = meta.attributes;
      switch (attr['property']) {
        case 'og:image':
          metaData.imageUrl = Uri.parse(attr['content']);
          break;
        case 'og:title':
          metaData.title = attr['content'];
          break;
        case 'og:url':
          metaData.url = Uri.parse(attr['content']);
          break;
        case 'og:site_name':
          metaData.siteName = attr['content'];
          break;
        case 'og:description':
          metaData.description = attr['content'];
          final len = metaData.description.length;
          final descLen = int.parse(model.descLength);
          if (len > descLen) {
            metaData.description =
                metaData.description.substring(0, int.parse(model.descLength)) +
                    '...';
          }
          break;
      }
    });

    return convertToResult(metaData);
  }
}
