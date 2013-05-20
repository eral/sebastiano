//#define INPUT_TEST_DISPLAY_DELTA_TIME
//#define INPUT_TEST_LOG_JOYSTICK_STATE

#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <SD.h>
#include <SPI.h>
#include <sebastiano_teatro.h>
#include <stddef.h>

namespace {
	const uint8_t c_tft_cs	= 10;
	const uint8_t c_tft_dc	= 8;
	const uint8_t c_tft_rst	= uint8_t(-1);
	const uint8_t c_sd_cs	= 4;

	Adafruit_ST7735 l_tft = Adafruit_ST7735(c_tft_cs, c_tft_dc, c_tft_rst);

	class joystick {
	public:
		struct button {
			enum {
				down,
				right,
				select,
				up,
				reserve4,
				left,

				max,
			};
		};
		static sebastiano::teatro::input_type update(void *data) {
			const int c_analog_offset = int(0.75f * (1 << 7));
			int pin3 = analogRead(3);
			uint8_t btn = (pin3 + c_analog_offset) >> 7;
			sebastiano::teatro::input_type result;
			result.axis[0] = result.axis[0] = int8_t(0);
			switch (btn) {
			case button::left:
				result.axis[0] = int8_t(-127);
				result.axis[1] = int8_t(0);
				break;
			case button::up:
				result.axis[0] = int8_t(0);
				result.axis[1] = int8_t(127);
				break;
			case button::right:
				result.axis[0] = int8_t(127);
				result.axis[1] = int8_t(0);
				break;
			case button::down:
				result.axis[0] = int8_t(0);
				result.axis[1] = int8_t(-127);
				break;
			default:
				result.axis[1] = result.axis[0] = int8_t(0);
				break;
			}
			result.button = ((btn < button::max)? (1 << btn): 0);

#if defined(INPUT_TEST_LOG_JOYSTICK_STATE)
			Serial.print("update_input(");
			Serial.print(reinterpret_cast<size_t>(data));
			Serial.print(") = {'x':");
			Serial.print(result.axis[0]);
			Serial.print(", 'y':");
			Serial.print(result.axis[1]);
			Serial.print(", 'btn':");
			print_bit(Serial, result.button);
			Serial.print("}; analogRead(3) = ");
			Serial.print(pin3);
			Serial.println(";");
#endif //defined(INPUT_TEST_LOG_JOYSTICK_STATE)

			return result;
		}
		static void print_bit(Print &print, uint8_t state) {
			for (uint8_t i = 8, i_end = 0; i != i_end; --i) {
				uint8_t value = ((state & (1 << (i-1)))? 1: 0);
				print.print(value);
			}
		}
	};

	class input_draw : public sebastiano::scena {
		static const int16_t c_font_size_x = 6;
		static const int16_t c_font_size_y = 8;
		static const int16_t c_axis_size_x = 60;
		static const int16_t c_axis_size_y = 60;
	public:
		void update(sebastiano::teatro &teatro) {
			l_tft.setTextSize(1);
			l_tft.setTextColor(ST7735_WHITE);

			l_tft.setCursor(c_font_size_x * 0, c_font_size_y * 0);
			l_tft.print("Direct :");
			l_tft.fillRect(c_font_size_x * 8, c_font_size_y * 0, c_font_size_x * 8, c_font_size_y * 1, ST7735_BLACK);
			print_bit(l_tft, teatro.get_direct_button());

			l_tft.setCursor(c_font_size_x * 0, c_font_size_y * 1);
			l_tft.print("Onedge :");
			l_tft.fillRect(c_font_size_x * 8, c_font_size_y * 1, c_font_size_x * 8, c_font_size_y * 1, ST7735_BLACK);
			print_bit(l_tft, teatro.get_onedge_button());

			l_tft.setCursor(c_font_size_x * 0, c_font_size_y * 2);
			l_tft.print("Offedge:");
			l_tft.fillRect(c_font_size_x * 8, c_font_size_y * 2, c_font_size_x * 8, c_font_size_y * 1, ST7735_BLACK);
			print_bit(l_tft, teatro.get_offedge_button());

			l_tft.setCursor(c_font_size_x * 0, c_font_size_y * 3);
			l_tft.print("Axis:");
			//l_tft.fillRect(c_font_size_x * 8, c_font_size_y * 3, c_axis_size_x, c_axis_size_y, ST7735_BLACK);
			l_tft.drawLine(c_font_size_x * 8
						, c_font_size_y * 3 + (c_axis_size_y >> 1)
						, c_font_size_x * 8 + c_axis_size_x
						, c_font_size_y * 3 + (c_axis_size_y >> 1)
						, ST7735_WHITE
						);
			l_tft.drawLine(c_font_size_x * 8 + (c_axis_size_x >> 1)
						, c_font_size_y * 3
						, c_font_size_x * 8 + (c_axis_size_x >> 1)
						, c_font_size_y * 3 + c_axis_size_y
						, ST7735_WHITE
						);
			sebastiano::teatro::input_axis_type axis = teatro.get_direct_axis();
			l_tft.drawLine(c_font_size_x * 8 + (c_axis_size_x >> 1)
						, c_font_size_y * 3 + (c_axis_size_y >> 1)
						, c_font_size_x * 8 + (c_axis_size_x >> 1) + (static_cast<int16_t>(axis.axis[0]) * (c_axis_size_x >> 1) / 127)
						, c_font_size_y * 3 + (c_axis_size_y >> 1) - (static_cast<int16_t>(axis.axis[1]) * (c_axis_size_y >> 1) / 127)
						, ST7735_RED
						);
		}
		static void print_bit(Print &print, uint8_t state) {
			for (uint8_t i = 8, i_end = 0; i != i_end; --i) {
				uint8_t value = ((state & (1 << (i-1)))? 1: 0);
				print.print(value);
			}
		}
	};
}


void setup(void) {
	Serial.begin(9600);
	l_tft.initR(INITR_REDTAB);
	Serial.println("TFT initialized.");
	l_tft.fillScreen(ST7735_BLACK);
	Serial.println("TFT cleared.");

	sebastiano::teatro &teatro = sebastiano::teatro::create_instance();
	teatro.set_input_function(joystick::update, NULL);
	teatro.push(new input_draw());

	Serial.println("setuped.");
}


void loop() {
	sebastiano::teatro &teatro = sebastiano::teatro::create_instance();
	teatro();

#if defined(INPUT_TEST_DISPLAY_DELTA_TIME)
	uint32_t delta_time = teatro.get_delta_us();

	l_tft.fillRect(0, 128, 128, 160-128, ST7735_BLACK);
	l_tft.setTextSize(1);
	l_tft.setTextColor(ST7735_WHITE);
	l_tft.setCursor(4, 132);
	l_tft.print("DeltaTime:");
	l_tft.print(delta_time);
	l_tft.print("us");
	l_tft.setCursor(4, 132+8);
	l_tft.print("FPS      :");
	l_tft.print(1000000.0f / static_cast<float>(delta_time));
	l_tft.print("f/s");
#endif //defined(INPUT_TEST_DISPLAY_DELTA_TIME)
}

