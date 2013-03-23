//------ Include ---------------------- インクルード ---------------------------
#include <sebastiano_teatro.h>


//------ Debug ------------------------ デバッグ -------------------------------
#if defined(_DEBUG)
#endif //#if defined(_DEBUG)


//------ Macro ------------------------ マクロ ---------------------------------
//==============================================================================
/*! lengthof
	長さ取得
	
	@param	ary	[in]	配列

	@return 長さ
	
	@note
		ポインタを入力すると誤った結果を返すので注意
/*///===========================================================================
#define	lengthof(ary)	(sizeof(ary)/sizeof(ary[0]))










namespace sebastiano {










//------ Class ------------------------ クラス ---------------------------------
//■//-- Local Constant --------------- ローカル定数 ---------------------------
uint8_t teatro::s_instance[sizeof(teatro)] = {uint8_t(-1)};


//■//-- Public Constant -------------- 公開定数 -------------------------------
//■//-- Public Function -------------- 公開関数 -------------------------------
//==============================================================================
/*! teatro::create_instance
	インスタンス構築

	@return インスタンス
/*///===========================================================================
teatro &teatro::create_instance()
{
	if (uint8_t(-1) == s_instance[0]) {
		new(s_instance) teatro();
	}
	return *reinterpret_cast<teatro *>(s_instance);
}

//==============================================================================
/*! teatro::operator()
	更新

	@return インスタンス
/*///===========================================================================
void teatro::operator()()
{
	//シーン切替・破棄(逆順)
	for (scena **scene = m_scene_buffer + m_scene_size, **scene_end = m_scene_buffer; scene != scene_end; --scene) {
		scena **crnt_scene = scene - 1;
		scena *next = (*crnt_scene)->next_update_pointer();
		if (*crnt_scene != next) {
			(*crnt_scene)->~scena();
			if (next) {
				*crnt_scene = next;
			} else if (scene == m_scene_buffer + m_scene_size) {
				//末端なら
				--m_scene_size;
			}
		}
	}

	{
		uint32_t update_time = micros();
		m_delta_us = update_time - m_last_update_time;
		m_last_update_time = update_time;
	}

	//シーン前更新(逆順)
	for (scena **scene = m_scene_buffer + m_scene_size, **scene_end = m_scene_buffer; scene != scene_end; --scene) {
		(*(scene - 1))->pre_update(*this);
	}
	//シーン更新(逆順)
	for (scena **scene = m_scene_buffer + m_scene_size, **scene_end = m_scene_buffer; scene != scene_end; --scene) {
		(*(scene - 1))->update(*this);
	}
	//シーン後更新(逆順)
	for (scena **scene = m_scene_buffer + m_scene_size, **scene_end = m_scene_buffer; scene != scene_end; --scene) {
		(*(scene - 1))->post_update(*this);
	}
	//シーン描画
	for (scena **scene = m_scene_buffer, **scene_end = m_scene_buffer + m_scene_size; scene != scene_end; ++scene) {
		(*scene)->draw();
	}
}

//==============================================================================
/*! teatro::push
	シーンプッシュ

	@param	scene	[in]	シーン

	@note
		シーンは破棄時に delete されます。
/*///===========================================================================
void teatro::push(scena *scene)
{
	if (m_scene_size < lengthof(m_scene_buffer)) {
		m_scene_buffer[m_scene_size++] = scene;
	}
}


//■//-- Get Function ----------------- 取得関数 -------------------------------
//==============================================================================
/*! teatro::get_delta_us
	前回からの経過マイクロ秒取得

	@return 前回からの経過マイクロ秒;
/*///===========================================================================
uint32_t teatro::get_delta_us() const
{
	return m_delta_us;
}


//■//-- Set Function ----------------- 設定関数 -------------------------------
//■//-- Constructor And Destructor --- コンストラクタ・デストラクタ -----------
//==============================================================================
/*! teatro::teatro
	デフォルトコンストラクタ
/*///===========================================================================
teatro::teatro(): m_scene_size(0)
{
	//m_scene_size は s_instance[0] と共有しています。
	//インスタンス未作成時を uint8_t(-1) == s_instance[0] としているので、
	//m_scene_size には uint8_t(-1) を代入しない事。
	
	for (scena **scene = m_scene_buffer, **scene_end = m_scene_buffer + m_scene_size; scene != scene_end; ++scene) {
		*scene = NULL;
	}

	m_last_update_time = micros();
	m_delta_us = 0;
}

//==============================================================================
/*! teatro::~teatro
	デストラクタ
/*///===========================================================================
teatro::~teatro()
{
	while (0 < m_scene_size) {
		m_scene_buffer[--m_scene_size]->~scena();
	}
}


//■//-- Local Function --------------- ローカル関数 ---------------------------
//==============================================================================
/*! teatro::new
	配置new

	@param	size	[in]	配置new構文
	@param	buf		[io]	配置new構文
/*///===========================================================================
void *teatro::operator new(size_t size, void *buf)
{
	*reinterpret_cast<uint8_t *>(buf) = uint8_t(0);
	return buf;
}

//==============================================================================
/*! teatro::delete
	配置delete

	@param	ptr	[io]	配置delete構文
	@param	buf	[io]	配置delete構文
/*///===========================================================================
void teatro::operator delete(void *ptr, void *buf)
{
	*reinterpret_cast<uint8_t *>(ptr) = uint8_t(-1);
}


//------------------------------------------------------------------------------










} //namespace sebastiano



