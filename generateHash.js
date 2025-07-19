const bcrypt = require("bcryptjs"); // or 'bcrypt'

const password = "Test@1234"; // Your test password
const saltRounds = 10;

bcrypt.hash(password, saltRounds, (err, hash) => {
  if (err) {
    console.error("Error generating hash:", err);
  } else {
    console.log("Hashed password:", hash);
  }
});

// INSERT INTO users (name, email, password) VALUES ('Test User', 'testuser@example.com', '$2b$10$xIgDWSfjfUY0nxImf0LCheDWPUKlFS8./MuUd.c8C8qh6Ix9AIQFC');

// INSERT INTO users ( organization_id, email, password_hash, first_name, last_name, role, status ) VALUES ( 3,
//   'testuser@example.com',
//  '$2b$10$xIgDWSfjfUY0nxImf0LCheDWPUKlFS8./MuUd.c8C8qh6Ix9AIQFC',
//     'Test',
//   'User',
//  'admin',
//  'active' );
