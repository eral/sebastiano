//#define DRAW_TEST_DISPLAY_DELTA_TIME

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

	class rect_draw : public sebastiano::scena {
		uint32_t	m_step_us;
		uint32_t	m_progress_us;
		uint8_t		m_x;
		uint8_t		m_y;
		uint8_t		m_w;
		uint8_t		m_h;
		uint16_t	m_clr;
		uint8_t		m_crnt_x;
		uint8_t		m_crnt_y;
	public:
		void update(sebastiano::teatro &teatro) {
			m_progress_us += teatro.get_delta_us();
			while (m_step_us <= m_progress_us) {
				uint8_t line = static_cast<uint8_t>(m_progress_us / (m_step_us * 10));
				if ((0 == m_crnt_x) && (0 < line)) {
					line = min(line, (m_h - m_crnt_y));
					l_tft.fillRect(m_x + m_crnt_x, m_y + m_crnt_y, m_w, line, m_clr);
					m_crnt_y += line;
					m_progress_us -= m_step_us * line * m_w;
				} else {
					l_tft.drawPixel(m_x + m_crnt_x, m_y + m_crnt_y, m_clr);
					++m_crnt_x;
					if (m_w <= m_crnt_x) {
						m_crnt_x = 0;
						++m_crnt_y;
					}
					m_progress_us -= m_step_us;
				}
				if (m_h <= m_crnt_y) {
					m_crnt_y = 0;
					l_tft.fillRect(m_x, m_y, m_w, m_h, ST7735_BLACK);
				}
			}
		}
		rect_draw(uint32_t step_us, uint8_t x, uint8_t y, uint8_t w, uint8_t h, uint16_t clr): m_step_us(step_us), m_progress_us(0), m_x(x), m_y(y), m_w(w), m_h(h), m_clr(clr), m_crnt_x(0), m_crnt_y(0) {
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
	teatro.push(new rect_draw(16666/ 3,   4, 4, 10, 120, ST7735_RED));
	teatro.push(new rect_draw(16666/ 5,  20, 4, 10, 120, ST7735_GREEN));
	teatro.push(new rect_draw(16666/ 7,  36, 4, 10, 120, ST7735_BLUE));
	teatro.push(new rect_draw(16666/11,  52, 4, 10, 120, ST7735_YELLOW));
	teatro.push(new rect_draw(16666/13,  68, 4, 10, 120, ST7735_MAGENTA));
	teatro.push(new rect_draw(16666/17,  84, 4, 10, 120, ST7735_CYAN));
	teatro.push(new rect_draw(16666/19, 100, 4, 10, 120, ST7735_WHITE));
	teatro.push(new rect_draw(16666/23, 116, 4, 10, 120, (0b10000 << 11) | (0b100000 << 5) | (0b10000 << 0)));

	Serial.println("setuped.");
}


void loop() {
	sebastiano::teatro &teatro = sebastiano::teatro::create_instance();
	teatro();

#if defined(DRAW_TEST_DISPLAY_DELTA_TIME)
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
#endif //defined(DRAW_TEST_DISPLAY_DELTA_TIME)
}

