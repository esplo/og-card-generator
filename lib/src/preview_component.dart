import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular/security.dart';

class PermissiveNodeValidator implements NodeValidator {
  bool allowsElement(Element element) => true;

  bool allowsAttribute(Element element, String attributeName, String value) {
    return true;
  }
}

@Pipe('safe')
class Safe extends PipeTransform {
  DomSanitizationService sanitizer;

  Safe(this.sanitizer);

  transform(style) {
    return this.sanitizer.bypassSecurityTrustStyle(style);
  }
}

@Component(
  selector: 'preview',
  pipes: [Safe],
  template: '''
  <div id="html-preview"
   [style]="'width: ' + width + 'px; height: ' + height + 'px; border: 1px dashed black;' | safe"
  ></div>
  ''',
  styleUrls: ['preview_component.css'],
)
class PreviewComponent {
  @Input()
  set setHtml(String html) {
    final _htmlValidator = PermissiveNodeValidator();
    querySelector('#html-preview')
        ?.setInnerHtml(html, validator: _htmlValidator);
  }

  @Input()
  String width;
  @Input()
  String height;
}
