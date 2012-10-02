CityBug Project (Beta v.1.0)

# API List

## README

การเข้าถึง API เบื้องต้นให้ใช้วิธี Basic Authentication

## REPORT

* Feed
	
	ใช้สำหรับแสดง feed ของ user ใดๆ เฉพาะสถานที่ที่ผู้ใช้ subscribe เอาไว้ 
		
		/api/reports

	* INPUT : User / Location / Subscription 
	* OUTPUT : sort by last modified / sort by location / show only subscribed post

		* Signed In & Location & Subscription >> user's feed & sort by last modified & show only subscribed post
		* Signed In & Location & No Subscription >> user's feed & sort by location
		* Signed In & No Location & Subscription >>  user's feed & sort by last modified & show only subscribed post 
		* Signed In & No Location & No Subscription >>  user's feed & sort by last modified 
		* Not Signed In & Location >> sort by location
		* Not Signed In & No Location  >>  sort by last modified 

	* [lat] - double
	* [lng] - double
	* [startDate] - เริ่มจากวันที่ ("yyyy-MM-dd HH:mm:ss")
	* [endDate] - สิ้นสุดวันที่ ("yyyy-MM-dd HH:mm:ss")
	* [limit] - number
	* HTTP Method - GET
	* Login required - YES
	* Response <span id="ref-a"></span>

				{ 
					"reports":[
								{
									"user":{
										"email":"123@ggg.com",
										"username":"admin",
										"_id":"505a9c25c6c280e578000001"
									},
									"created_at":"2012-09-20T07:32:48.090Z",
									"last_modified":"2012-09-20T07:32:48.090Z",
									"imin_count":1,
									"is_resolved":false,
									"note":"ท่อตันทั้งสาย",
									"lng":10.329,
									"lat":99.1245,
									"full_image":"/images/report/505ac6a025aad95080000001.png",
									"thumbnail_image":"/images/report/505ac6a025aad95080000001_thumbnail.png",
									"title":"น้ำท่วม",
									"_id":"505ac6a025aad95080000001",
									"__v":0,
									"imins":[
										{
											"user":{
												"email":"123@ggg.com",
												"username":"admin",
												"_id":"505a9c25c6c280e578000001"
											},
											"last_modified":"2012-09-20T07:32:48.090Z"
										}
									],
									"comments":[
										{
											"text":"น่าสงสารจัง",
											"user":{
												"email":"123@ggg.com",
												"username":"admin",
												"_id":"505a9c25c6c280e578000001"
											},
											"last_modified":"2012-09-20T07:32:48.090Z"
										},
										{
											"text":"สู้ๆนะคะ",
											"user":{
												"email":"123@ggg.com",
												"username":"admin",
												"_id":"505a9c25c6c280e578000001"
											},
											"last_modified":"2012-09-20T07:32:48.090Z"
										}
									],
									"categories":[
										{
											"title":"cat1",
											"_id":"505a8ef3cea52e3676000001"
										}
									], 
									"place":[
										{
											"title":"น้ำเรื่มท่วม"
											"lat":11.50
											"lng":11.2
											"last_modified":"2012-09-20T07:32:48.090Z"
											"_id":"505a9c25c6c280e578000002"
										}
									]
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
	* Response Status
		* 200 - OK (text = 'posted')
		* 401 - Unauthorized
		* 500 - server failed 

## CATEGORY

* list
		
	ในเบื้องต้นใช้การกำหนดรายการ category จากเซิร์ฟเวอร์เท่านั้น

		/api/categories

	* Response

				{
				    "categories": [
				        {
				            "created_at": "2012-09-20T03:35:15.853Z",
				            "last_modified": "2012-09-20T03:35:15.853Z",
				            "title": "cat1",
				            "_id": "505a8ef3cea52e3676000001",
				            "__v": 0
				        },
				        {
				            "created_at": "2012-09-20T03:35:15.853Z",
				            "last_modified": "2012-09-20T03:35:15.853Z",
				            "title": "cat2",
				            "_id": "505a8ef3cea52e3676000002",
				            "__v": 0
				        }
				    ]
				}
	* Response Status
		* 200 - OK
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
		* 200 - OK (text = 'commented')
		* 401 - Unauthorized
		* 500 - server failed 
	* HTTP Method - POST
	* Login required - YES

* list
	
	เรียกใช้เพื่อแสดง feed ของ report นั้นๆ
		
		/api/report/[id]
	* Response (will update later 18/09/2012)

				{
				    "reports": [
				        {
				            "user": {
				                "email": "admin@citybug.in.th",
				                "username": "admin",
				                "_id": "50617a63b345825eb9000001"
				            },
				            "_id": "506262ade9d05a37bf000004",
				            "comments": [
				                {
				                    "created_at": "2012-09-26T02:08:23.478Z",
				                    "last_modified": "2012-09-26T02:08:23.478Z",
				                    "report": "506262ade9d05a37bf000004",
				                    "user": {
				                        "email": "admin@citybug.in.th",
				                        "username": "admin",
				                        "_id": "50617a63b345825eb9000001"
				                    },
				                    "text": "ป่าหายไปหนึ่งในหนึ่ง(หายหมดเลย)",
				                    "_id": "50626397e9d05a37bf000007",
				                    "__v": 0
				                },
				                {
				                    "created_at": "2012-09-26T02:08:31.519Z",
				                    "last_modified": "2012-09-26T02:08:31.519Z",
				                    "report": "506262ade9d05a37bf000004",
				                    "user": {
				                        "email": "admin@citybug.in.th",
				                        "username": "admin",
				                        "_id": "50617a63b345825eb9000001"
				                    },
				                    "text": "ตอผุด",
				                    "_id": "5062639fe9d05a37bf000008",
				                    "__v": 0
				                }
				            ],
				            "title": "น้ำป่าไหลหลาก",
				            "lat": 10,
				            "lng": 11.111,
				            "note": "ต้นไม้หายหมด",
				            "full_image": "/images/report/506262ade9d05a37bf000004.png",
				            "thumbnail_image": "/images/report/506262ade9d05a37bf000004_thumbnail.png",
				            "is_resolved": false,
				            "categories": [],
				            "place": {
				                "created_at": "2012-09-25T09:33:29.784Z",
				                "last_modified": "2012-09-25T09:33:29.784Z",
				                "lng": -73.98427,
				                "lat": 40.720658,
				                "title": "the living theater",
				                "id_foursquare": "4ada58f4f964a520a52121e3",
				                "_id": "50617a69b345825eb900000b",
				                "__v": 0
				            },
				            "imins": [],
				            "last_modified": "2012-09-26T02:04:29.818Z",
				            "created_at": "2012-09-26T02:04:29.818Z"
				        }
				    ]
				}
	* HTTP Method - GET
	* Login required - NO

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
	* [limit] - default is 30 (foursquare using 50)
	* [username] - string (หากเป็นการค้นหาสถานที่ใกล้เคียง ให้ระบุ username เพื่อค้นหาจากสถานที่ใน CityBug ก่อน โดยจำเป็นต้องใช้ text ควบคู่ด้วย) 
	* HTTP Method - GET
	* Login required - NO


				{
				    "places": [
				        {
				            "distance": 573.957270641795,
				            "type": "suggested",
				            "created_at": "2012-09-26T11:14:46.226Z",
				            "last_modified": "2012-09-26T11:14:46.226Z",
				            "lng": 100.5882775783539,
				            "lat": 13.79115507139444,
				            "title": "Opendream (โอเพ่นดรีม)",
				            "id_foursquare": "4b0e2fdcf964a520bb5523e3",
				            "_id": "5062e3a67ceca86a1b000040",
				            "__v": 0
				        },
				        {
				            "distance": 11098.824523639349,
				            "type": "suggested",
				            "created_at": "2012-09-25T08:57:51.018Z",
				            "last_modified": "2012-09-25T08:57:51.018Z",
				            "lng": 40.7209,
				            "lat": -73.98428,
				            "title": "สวนดอกจ้า",
				            "id_foursquare": "mockupplaceid",
				            "_id": "5061720f8a1b2f8012000008",
				            "__v": 0
				        },
				        {
				            "distance": 11098.829948544852,
				            "type": "suggested",
				            "created_at": "2012-09-25T08:55:37.905Z",
				            "last_modified": "2012-09-25T08:55:37.905Z",
				            "lng": 40.720658,
				            "lat": -73.98427,
				            "title": "the living theater",
				            "id_foursquare": "4ada58f4f964a520a52121e3",
				            "_id": "506171898a1b2f8012000006",
				            "__v": 0
				        },
				        {
				            "created_at": "2012-09-27T06:50:53.689Z",
				            "last_modified": "2012-09-27T06:50:53.689Z",
				            "lng": 98.931842,
				            "lat": 18.702243,
				            "type": "additional",
				            "distance": 12,
				            "title": "Rimping Supermarket Kad Farang",
				            "id_foursquare": "5016581be4b034c3e0ffc4e0",
				            "_id": "5063f74d596ed4ba1f000040"
				        },
				        {
				            "created_at": "2012-09-27T06:50:53.690Z",
				            "last_modified": "2012-09-27T06:50:53.690Z",
				            "lng": 98.931801,
				            "lat": 18.702001,
				            "type": "additional",
				            "distance": 25,
				            "title": "ร้านอาหารลานทะเล (สด)",
				            "id_foursquare": "4f0ecf77e4b09cff0124e90a",
				            "_id": "5063f74d596ed4ba1f000041"
				        },
				        {
				            "created_at": "2012-09-27T06:50:53.690Z",
				            "last_modified": "2012-09-27T06:50:53.690Z",
				            "lng": 98.93209408898043,
				            "lat": 18.702113063963708,
				            "type": "additional",
				            "distance": 40,
				            "title": "Ye Olde English Pub",
				            "id_foursquare": "4ecfa05fd3e3521ce4afa244",
				            "_id": "5063f74d596ed4ba1f000044"
				        },
				        {
				            "created_at": "2012-09-27T06:50:53.691Z",
				            "last_modified": "2012-09-27T06:50:53.691Z",
				            "lng": 98.932136,
				            "lat": 18.702232,
				            "type": "additional",
				            "distance": 42,
				            "title": "Rosewood @ Kad Farang",
				            "id_foursquare": "4cd4f55ba5b346884e4c8b50",
				            "_id": "5063f74d596ed4ba1f000047"
				        },
				        {
				            "created_at": "2012-09-27T06:50:53.801Z",
				            "last_modified": "2012-09-27T06:50:53.801Z",
				            "lng": 98.93215,
				            "lat": 18.702265,
				            "type": "additional",
				            "distance": 44,
				            "title": "RoSEwoOD.. กาดฝรั่ง ",
				            "id_foursquare": "4eb62590469073bbc679d39e",
				            "_id": "5063f74d596ed4ba1f00004a"
				        },
				        {
				            "created_at": "2012-09-27T06:50:53.804Z",
				            "last_modified": "2012-09-27T06:50:53.804Z",
				            "lng": 98.932203,
				            "lat": 18.702104,
				            "type": "additional",
				            "distance": 51,
				            "title": "Kiean Sushi",
				            "id_foursquare": "4b8cfcf0f964a52050e332e3",
				            "_id": "5063f74d596ed4ba1f000057"
				        },
				        {
				            "created_at": "2012-09-27T06:50:53.690Z",
				            "last_modified": "2012-09-27T06:50:53.690Z",
				            "lng": 98.93156582638261,
				            "lat": 18.7017658226588,
				            "type": "additional",
				            "distance": 53,
				            "title": "กาดฝรั่ง",
				            "id_foursquare": "4b8cfc69f964a5203ce332e3",
				            "_id": "5063f74d596ed4ba1f000042"
				        }
				    ]
				}

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
	* Login required - NO
	* Response Status
		* 200 - OK (text = 'registered')
		* 500 - Server fail (text = 'user exit') 

* sign in
	
		 /api/user/sign_in
	* HTTP Method - POST
	* Login required - NO
	* Response Status
		* 200 - OK (text = 'authenticated')
		* 401 - Unauthorized 

* sign out
	
		 /api/user/sign_out
	* HTTP Method - GET
* subscribes
	
		 /api/user/:username/subscribes

* reports
	
		 /api/report/:username
	* Response Status
		* 200 - OK
