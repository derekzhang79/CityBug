CityBug Project (Beta v.1.0)

# API List

## README

การเข้าถึง API เบื้องต้นให้ใช้วิธี Basic Authentication

## REPORT

* Feed
	
	ใช้สำหรับแสดง feed ของ user ใดๆ เฉพาะสถานที่ที่ผู้ใช้ subscribe เอาไว้ 
	
		/api/reports
	
	* [startDate] - เริ่มจากวันที่ ("yyyy-MM-dd HH:mm:ss")
	* [endDate] - สิ้นสุดวันที่ ("yyyy-MM-dd HH:mm:ss")
	* [limit] - number
	* HTTP Method - GET
	* Login required - YES
	* Response <span id="ref-a"></span>

				{
					"entries": [
						{
							"id": 1
							"title": "lorem ipsum",
							"place": {
								"name": "opendream",
								"lat": 10.32354,
								"lng": 133.3450
							},
							"comments": [
								{
									"id": 1
									"text": "I love it"
								}
							],
							"categories": ["A", "B"]
						}
					]
				}

* Most Recent

	ใช้ในกรณีที่ไม่ได้เข้าใช้งาน (sign in) หากไม่สามารถค้นหา latitude และ longitude จะ response เป็น reports ล่าสุด

		/api/reports?

	* [lat] - double
	* [lng] - double
	* [startDate] - เริ่มจากวันที่ ("yyyy-MM-dd HH:mm:ss")
	* [endDate] - สิ้นสุดวันที่ ("yyyy-MM-dd HH:mm:ss")
	* [limit] - number
	* HTTP Method - GET
	* Login required - NO
	* Response - [reference](#ref-a)

* create
	
	ทุก fields ต้องระบุ
	หากผู้ใช้เลือกรูปถ่ายจาก library จะต้องดึงตำแหน่งมาใช้เพื่อระบุ latitude และ longitude
	หาก latitude และ longitude ไม่สามารถระบุได้ ให้แจ้งเตือนผู้ใช้ และยกเลิกการรายงาน

		/api/report

	* [title] - string up to 256 characters
	* [note] - string up to 1024 characters
	* [place_id] - id
	* [latitude] - double
	* [longitude] - double
	* [photo] - Content-Type='image/jpeg'
	* [categories] - string
	* HTTP Method - POST
	* Login required - YES

## CATEGORY

* list
		
	ในเบื้องต้นใช้การกำหนดรายการ category จากเซิร์ฟเวอร์เท่านั้น

		/api/categories

	* Response

				{
					"categores": ["A", "B", "C"]
				}
	* Response Status
		* 1000 - Unknown
		* 1001 - OK
		* 1002 - Time out
		* 1003 - Failed 
	* HTTP Method - GET
	* Login required - NO

## COMMENT

* create
	
	เรียกใช้เพื่อเพิ่ม comment ไปยัง report ใดๆ
		
		/api/report/[id]/comment
	* [text] - string up to 256 characters
	* Response (will update later 18/09/2012)

				{
					"status": 1001,
					"error": "invalid report identifier(report_id)"
				}
	* Response Status
		* 2000 - Unknown
		* 2001 - OK
		* 2002 - Time out
		* 2003 - Failed 
	* HTTP Method - POST
	* Login required - YES

## LIKE (a.k.a "I'm in")

* I'm in

		/api/report/[id]/im_in

	* HTTP Method - POST
	* Login required - YES
* I'm out
		
		/api/report/[id]/im_out
	* HTTP Method - POST
	* Login required - YES

## PLACE

* search
		
	ใช้ค้นหาสถานที่จากตำแหน่งปัจจุบัน ถ้าหากไม่สามารถระบุตำแหน่งได้ สามารถระบุคำค้นด้วยชื่อ
	สามารถระบุคำค้นด้วยชื่อสถานที่สำคัญ 

		/api/place/search?
	* [text] - string
	* [lat] - double
	* [lng] - double
	* [limit] - default is 30 (foursqure using 50)
	* [username] - string (หากเป็นการค้นหาสถานที่ใกล้เคียง ให้ระบุ username เพื่อค้นหาจากสถานที่ใน CityBug ก่อน โดยจำเป็นต้องใช้ text ควบคู่ด้วย) 
	* HTTP Method - GET
	* Login required - NO

* view
	
		/api/place/[id]
	* HTTP Method - GET
	* Login required - NO

* subscribe
		
		/api/place/[id]/subscribe
	* HTTP Method - POST
	* Login required - YES

* unsubscribe
		
		/api/place/[id]/unsubscribe
	* HTTP Method - POST
	* Login required - YES

## USER
* sign up
	
		 /api/user/create
	* [username] - string 
	* [password] - string at least 8 characters
	* HTTP Method - POST
	* Login required - YES

* sign in
	
		 /api/user/sign_in

* sign out
	
		 /api/user/sign_out

* subscribes
	
		 /api/user/:username/subscribes

* reports
	
		 /api/report/:username
