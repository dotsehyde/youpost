const express = require('express');
require('dotenv').config();
const path = require('path');
const multer = require('multer');
const bodyParser = require('body-parser');
const mysql = require('mysql');
const fs = require('fs');

const app = express();
app.use(express.json());
app.use(bodyParser.urlencoded({ extended: false }));

const storage = multer.diskStorage({
	destination: function (req, file, cb) {
		cb(null, 'uploads/'); // Specify the directory where you want to store the uploaded files
	},
	filename: function (req, file, cb) {
		const uniqueSuffix = Math.round(Math.random() * 1E9);
		const ext = path.extname(file.originalname);
		cb(null, file.fieldname + '-' + uniqueSuffix + ext);
	},
});


const upload = multer({ storage: storage });

const db = mysql.createConnection({
	host: process.env.HOST,
	user: "root",
	password: process.env.PASS,
	database: process.env.DB,
});
// Connect to the database
db.connect((err) => {
	if (err) {
		console.error('Error connecting to MySQL:', err);
		return;
	}
});

//get media
app.get('/media/:name', async (req, res) => {
	try {
		const { name } = req.params;
		return res.sendFile(path.join(__dirname, `./uploads/${name}`));
	} catch (error) {
		return res.status(500).json({ status: 500, "message": error.message });
	}
})

//Create Post
app.post('/createPost', upload.single("photo"), async (req, res) => {
	try {
		const { title, content } = req.body;
		const file = req.file;
		if (!file) {
			res.status(400).json({ status: 400, message: "Please upload an image" });
			return;
		}
		const { base } = path.parse(file.path);

		let url = `${process.env.BASE_URL}/media/${base}`;

		db.query(`INSERT INTO posts(title,content,image) VALUES ("${title}","${content}","${url}")`, (queryErr, results) => {
			if (queryErr) {
				return res.status(500).json({ status: 500, "message": queryErr.message });
			}
			return res.status(200).json({
				status: 200,
				message: "Post created successfully",
				data: {
					id: results.insertId,
					title, content,
					image: url
				}
			})
		});

	} catch (error) {
		return res.status(500).json({ status: 500, "message": error.message });
	}
})

//Get all posts
app.get('/posts', async (req, res) => {
	try {
		db.query(`SELECT * FROM posts`, (queryErr, results) => {
			if (queryErr) {
				return res.status(500).json({ status: 500, "message": queryErr.message });
			}

			let data = results
			return res.status(200).json({ status: 200, message: "Posts fetched successfully", data })
		});
	} catch (error) {
		return res.status(500).json({ status: 500, "message": error.message });
	}
})

//Get single post
app.get('/post/:id', async (req, res) => {
	try {
		db.query(`SELECT * FROM posts WHERE id=${req.params.id}`, (queryErr, results) => {
			if (queryErr) {
				return res.status(500).json({ status: 500, "message": queryErr.message });
			}
			if (results.length == 0) {
				return res.status(404).json({ status: 404, message: "Post not found" })
			}
			return res.status(200).json({ status: 200, message: "Post fetched successfully", data: results[0] })
		});
	} catch (error) {
		return res.status(500).json({ status: 500, "message": error.message });
	}
})

//Update post
app.put('/post/:id', async (req, res) => {
	try {
		const { title, content } = req.body;
		db.query(`UPDATE posts SET title="${title}",content="${content}" WHERE id=${req.params.id}`, (queryErr, results) => {
			if (queryErr) {
				return res.status(500).json({ status: 500, "message": queryErr.message });
			}
			//get updated post
			db.query(`SELECT * FROM posts WHERE id=${req.params.id}`, (queryErr, results) => {
				if (queryErr) {
					return res.status(500).json({ status: 500, "message": queryErr.message });
				}
				return res.status(200).json({ status: 200, message: "Post updated successfully", data: results[0] })
			});
		});
	} catch (error) {
		return res.status(500).json({ status: 500, "message": error.message });
	}
})

//Delete post
app.delete('/post/:id', async (req, res) => {
	try {
		//get post
		db.query(`SELECT * FROM posts WHERE id=${req.params.id}`, (queryErr, results) => {
			if (queryErr) {
				return res.status(500).json({ status: 500, "message": queryErr.message });
			}
			if (results.length == 0) {
				return res.status(404).json({ status: 404, message: "Post not found" })
			}
			//delete post image
			let { image } = results[0];
			let { base } = path.parse(image);
			fs.unlinkSync(path.join(__dirname, `./uploads/${base}`));

			db.query(`DELETE FROM posts WHERE id=${req.params.id}`, (queryErr, results) => {
				if (queryErr) {
					return res.status(500).json({ status: 500, "message": queryErr.message });
				}
				return res.status(200).json({ status: 200, message: "Post deleted successfully" })
			});
		});
	} catch (error) {
		return res.status(500).json({ status: 500, "message": error.message });
	}
})

app.listen(process.env.PORT || 9090, () => {
	console.log(`Server started on port ${process.env.PORT || 9090}`);
})