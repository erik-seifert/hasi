// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:hasi/widgets/entities/camera_widget.dart'
    as _hasi_widgets_entities_camera_widget;
import 'package:hasi/widgets/entities/climate_widget.dart'
    as _hasi_widgets_entities_climate_widget;
import 'package:hasi/widgets/entities/light_widget.dart'
    as _hasi_widgets_entities_light_widget;
import 'package:hasi/widgets/entities/media_player_widget.dart'
    as _hasi_widgets_entities_media_player_widget;
import 'package:hasi/widgets/entities/sensor_widget.dart'
    as _hasi_widgets_entities_sensor_widget;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'widgets',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'entities',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CameraWidget',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _hasi_widgets_entities_camera_widget
                    .buildCameraWidgetUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClimateWidget',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Full Featured',
                builder: _hasi_widgets_entities_climate_widget
                    .buildClimateWidgetFullUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Simple',
                builder: _hasi_widgets_entities_climate_widget
                    .buildClimateWidgetSimpleUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'LightWidget',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Color Temp Light',
                builder: _hasi_widgets_entities_light_widget
                    .buildLightWidgetTempUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'RGB Light',
                builder: _hasi_widgets_entities_light_widget
                    .buildLightWidgetRGBUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'MediaWidget',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Paused',
                builder: _hasi_widgets_entities_media_player_widget
                    .buildMediaWidgetPausedUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Playing',
                builder: _hasi_widgets_entities_media_player_widget
                    .buildMediaWidgetPlayingUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SensorWidget',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Humidity',
                builder: _hasi_widgets_entities_sensor_widget
                    .buildHumiditySensorUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Temperature',
                builder: _hasi_widgets_entities_sensor_widget
                    .buildTemperatureSensorUseCase,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
