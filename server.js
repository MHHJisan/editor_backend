require("dotenv").config();
const express = require("express");
const http = require("http");
const cors = require("cors");
const pool = require("./config/db");
const { Server } = require("socket.io");
const { v4: uuidv4 } = require("uuid");
const CryptoJS = require("crypto-js");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const app = express();
const server = http.createServer(app);

// Configure CORS to allow frontend access
const io = new Server(server, {
  cors: {
    origin: process.env.CLIENT_URL || "http://localhost:3000",
    methods: ["GET", "POST", "PUT", "DELETE"],
  },
});

app.use(
  cors({
    origin: process.env.CLIENT_URL || "http://localhost:3001",
    methods: ["GET", "POST", "PUT", "DELETE"],
  })
);
app.use(express.json());

const SECRET_KEY = process.env.JWT_SECRET || "your-very-secure-secret-key";
const ENCRYPTION_KEY =
  process.env.ENCRYPTION_KEY || "your-very-secure-secret-key";

// Database operations
const dbOps = {
  // User Management
  async registerUser(
    orgId,
    email,
    password,
    firstName,
    lastName,
    role,
    department,
    template_approver,
    status = "active"
  ) {
    const passwordHash = await bcrypt.hash(password, 10);
    const [result] = await pool.execute(
      "INSERT INTO users (organization_id, email, password_hash, first_name, last_name, role, department, template_approver, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [
        orgId,
        email,
        passwordHash,
        firstName,
        lastName,
        role,
        department,
        template_approver,
        status,
      ]
    );
    return result.insertId;
  },

  async loginUser(email) {
    const [users] = await pool.execute(
      "SELECT id, email, password_hash, first_name, last_name, role, department, template_approver, organization_id FROM users WHERE email = ? AND status = ?",
      [email, "active"]
    );
    return users[0];
  },

  async inviteUser(orgId, email, role, department, message, status) {
    const [result] = await pool.execute(
      "INSERT INTO invited_users (organization_id, email, role, department, message, status) VALUES (?, ?, ?, ?, ?, ?)",
      [orgId, email, role, department, message, status]
    );
    return result.insertId;
  },

  // Check if invitation exists
  async checkInvitation(token) {
    try {
      const decoded = jwt.verify(token, ENCRYPTION_KEY);

      const [invitations] = await pool.execute(
        'SELECT * FROM invited_users WHERE email = ? AND status = "invited"',
        [decoded.email]
      );

      if (invitations.length === 0) {
        return null;
      }

      return {
        ...invitations[0],
        ...decoded, // Merge the decoded data from token
      };
    } catch (error) {
      console.error("Error checking invitation:", error);
      return null;
    }
  },

  async registerInvitedUser(
    orgId,
    email,
    password,
    firstName,
    lastName,
    role,
    department,
    status
  ) {
    const hashedPassword = await bcrypt.hash(password, 10);

    // Update invitation status
    const [result] = await pool.execute(
      "UPDATE invited_users SET password_hash = ?, first_name = ?, last_name = ?, role = ?, department = ?, status = ? WHERE email = ? AND organization_id = ?",
      [
        hashedPassword,
        firstName,
        lastName,
        role,
        department,
        "pending",
        email,
        orgId,
      ]
    );
    return result;
  },

  async updateUserProfile(userId, data) {
    const {
      firstName,
      lastName,
      email,
      department,
      status,
      template_approver,
    } = data;
    await pool.execute(
      "UPDATE users SET first_name = ?, last_name = ?, email = ?, department = ?, status = ?, template_approver = ? WHERE id = ?",
      [
        firstName,
        lastName,
        email,
        department,
        status,
        template_approver,
        userId,
      ]
    );
  },

  async changeUserRole(userId, newRole) {
    await pool.execute("UPDATE users SET role = ? WHERE id = ?", [
      newRole,
      userId,
    ]);
  },

  // Get Dashboard Data
  async listOrganizationUsers(userId) {
    const [orgResults] = await pool.execute(
      "SELECT organization_id FROM users WHERE id = ? AND status = ?",
      [userId, "active"]
    );

    const orgId = orgResults[0].organization_id;
    const [users] = await pool.execute(
      "SELECT * FROM users WHERE organization_id = ? AND status != ?",
      [orgId, "inactive"]
    );
    return users;
  },

  async listInvitedUsers(userId) {
    const [orgResults] = await pool.execute(
      "SELECT organization_id FROM users WHERE id = ? AND status = ?",
      [userId, "active"]
    );

    const orgId = orgResults[0].organization_id;
    const [users] = await pool.execute(
      "SELECT * FROM invited_users WHERE organization_id = ?",
      [orgId]
    );
    return users;
  },

  async getAllDocuments() {
    const [docs] = await pool.execute("SELECT * FROM documents");
    return docs;
  },

  async getUserAccessibleDocuments(userId) {
    const [docs] = await pool.execute(
      "SELECT * FROM documents d JOIN documentpermissions dp ON d.document_id = dp.document_id WHERE dp.user_id = ? AND dp.status = ?",
      [userId, "active"]
    );
    return docs;
  },

  async getTasks(userId) {
    const [tasks] = await pool.execute(
      `SELECT t.* FROM tasks t JOIN taskassignments ta ON t.id = ta.task_id WHERE ta.assigned_to = ? AND ta.status != 'completed'`[
        userId
      ]
    );
    return tasks;
  },

  async getTemplates(userId) {
    const [templates] = await pool.execute(
      "SELECT t.* FROM templates t JOIN users u ON t.organization_id = u.organization_id WHERE u.id = ?",
      [userId]
    );
    return templates;
  },

  async getEvents(userId) {
    const [events] = await pool.execute(
      `SELECT e.* FROM events e JOIN eventparticipants ep ON e.id = ep.event_id WHERE ep.user_id = ? AND e.status = 'scheduled' AND e.end_time > NOW() ORDER BY e.start_time ASC`,
      [userId]
    );
    return events;
  },

  // Document Management
  async createDocument(data) {
    const {
      orgId,
      templateId,
      title,
      content,
      elements,
      createdBy,
      status = "draft",
      coverPageData,
    } = data;
    const docId = uuidv4();
    await pool.execute(
      "INSERT INTO documents (id, organization_id, template_id, title, content, elements, current_revision, created_by, status, cover_page_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [
        docId,
        orgId,
        templateId,
        title,
        JSON.stringify(content || {}),
        JSON.stringify(elements || {}),
        1.0,
        createdBy,
        status,
        JSON.stringify(coverPageData || {}),
      ]
    );
    return docId;
  },

  async updateDocumentStatus(docId, status) {
    await pool.execute(
      "UPDATE documents SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
      [status, docId]
    );
  },

  async getDocumentById(docId) {
    const [docs] = await pool.execute(
      "SELECT * FROM documents WHERE document_id = ?",
      [docId]
    );
    return docs[0];
  },

  async searchDocuments(searchTerm) {
    const [docs] = await pool.execute(
      "SELECT id, title, status FROM documents WHERE title LIKE ? OR content LIKE ?",
      [`%${searchTerm}%`, `%${searchTerm}%`]
    );
    return docs;
  },

  async getDocumentRevisionHistory(docId) {
    const [revisions] = await pool.execute(
      "SELECT dr.revision_number, dr.created_at, u.first_name, u.last_name FROM documentrevisions dr JOIN users u ON dr.created_by = u.id WHERE dr.document_id = ? ORDER BY dr.revision_number DESC",
      [docId]
    );
    return revisions;
  },

  async createDocumentRevision(
    docId,
    revisionNumber,
    content,
    elements,
    createdBy,
    status = "draft"
  ) {
    await pool.execute(
      "INSERT INTO documentrevisions (document_id, revision_number, content, elements, created_by, status) VALUES (?, ?, ?, ?, ?, ?)",
      [
        docId,
        revisionNumber,
        JSON.stringify(content),
        JSON.stringify(elements),
        createdBy,
        status,
      ]
    );
  },

  // Document Permissions
  async addDocumentPermission(docId, userId, permissionType, assignedBy) {
    await pool.execute(
      "INSERT INTO documentpermissions (document_id, user_id, permission_type, assigned_by, status) VALUES (?, ?, ?, ?, ?)",
      [docId, userId, permissionType, assignedBy, "active"]
    );
  },

  async requestDocumentAccess(docId, requestedBy, permissionType) {
    await pool.execute(
      "INSERT INTO accessrequests (document_id, requested_by, requested_permission_type, status) VALUES (?, ?, ?, ?)",
      [docId, requestedBy, permissionType, "pending"]
    );
  },

  async getPendingAccessRequests(docId) {
    const [requests] = await pool.execute(
      "SELECT ar.id, ar.requested_by, ar.requested_permission_type, u.first_name, u.last_name, u.email FROM accessrequests ar JOIN users u ON ar.requested_by = u.id WHERE ar.document_id = ? AND ar.status = ?",
      [docId, "pending"]
    );
    return requests;
  },

  async approveAccessRequest(requestId, resolvedBy) {
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();

      // Update request status
      await connection.execute(
        "UPDATE accessrequests SET status = ?, resolved_by = ?, resolved_at = CURRENT_TIMESTAMP WHERE id = ?",
        ["approved", resolvedBy, requestId]
      );

      // Get request details
      const [requests] = await connection.execute(
        "SELECT document_id, requested_by, requested_permission_type, resolved_by FROM accessrequests WHERE id = ?",
        [requestId]
      );
      const request = requests[0];

      // Create permission
      await connection.execute(
        "INSERT INTO documentpermissions (document_id, user_id, permission_type, assigned_by, status) VALUES (?, ?, ?, ?, ?)",
        [
          request.document_id,
          request.requested_by,
          request.requested_permission_type,
          request.resolved_by,
          "active",
        ]
      );

      await connection.commit();
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  },

  // Template Management

  // Review Management
  async setupReviewStage(docId, stageOrder, stageType, isMandatory = true) {
    const [result] = await pool.execute(
      "INSERT INTO reviewstages (document_id, stage_order, stage_type, is_mandatory) VALUES (?, ?, ?, ?)",
      [docId, stageOrder, stageType, isMandatory ? 1 : 0]
    );
    return result.insertId;
  },

  async assignReviewer(stageId, userId, isMandatory = true) {
    await pool.execute(
      "INSERT INTO reviewassignments (review_stage_id, user_id, is_mandatory) VALUES (?, ?, ?)",
      [stageId, userId, isMandatory ? 1 : 0]
    );
  },

  async getPendingReviews(userId) {
    const [reviews] = await pool.execute(
      "SELECT d.document_id, d.title, rs.id AS review_stage_id FROM documents d JOIN reviewstages rs ON d.document_id = rs.document_id JOIN reviewassignments ra ON rs.id = ra.review_stage_id WHERE ra.user_id = ? AND ra.status = ?",
      [userId, "pending"]
    );
    return reviews;
  },

  // Task Management
  async createTask(orgId, title, description, dueDate, priority, createdBy) {
    const [result] = await pool.execute(
      "INSERT INTO tasks (organization_id, title, description, due_date, priority, created_by, status) VALUES (?, ?, ?, ?, ?, ?, ?)",
      [orgId, title, description, dueDate, priority, createdBy, "not_started"]
    );
    return result.insertId;
  },

  async assignTask(taskId, assignedTo, assignedBy) {
    await pool.execute(
      "INSERT INTO taskassignments (task_id, assigned_to, assigned_by, status) VALUES (?, ?, ?, ?)",
      [taskId, assignedTo, assignedBy, "pending"]
    );
  },

  async completeTask(taskId, userId) {
    await pool.execute(
      "UPDATE taskassignments SET status = ?, completed_at = CURRENT_TIMESTAMP WHERE task_id = ? AND assigned_to = ?",
      ["completed", taskId, userId]
    );

    await pool.execute(
      `
      UPDATE tasks t
      SET status = 
        CASE
          WHEN (SELECT COUNT(*) FROM taskassignments WHERE task_id = t.id) = 
               (SELECT COUNT(*) FROM taskassignments WHERE task_id = t.id AND status = 'completed')
          THEN 'completed'
          WHEN (SELECT COUNT(*) FROM taskassignments WHERE task_id = t.id AND status = 'in_progress') > 0
          THEN 'in_progress'
          ELSE t.status
        END
      WHERE id = ?`,
      [taskId]
    );
  },

  // Event Management
  async createEvent(orgId, title, description, startTime, endTime, createdBy) {
    const [result] = await pool.execute(
      "INSERT INTO events (organization_id, title, description, start_time, end_time, created_by, status) VALUES (?, ?, ?, ?, ?, ?, ?)",
      [orgId, title, description, startTime, endTime, createdBy, "scheduled"]
    );
    return result.insertId;
  },

  async addEventParticipant(eventId, userId) {
    await pool.execute(
      "INSERT INTO eventparticipants (event_id, user_id, status) VALUES (?, ?, ?)",
      [eventId, userId, "invited"]
    );
  },

  async acceptEventInvitation(eventId, userId) {
    await pool.execute(
      "UPDATE eventparticipants SET status = ? WHERE event_id = ? AND user_id = ?",
      ["accepted", eventId, userId]
    );
  },

  async linkDocumentsToEvent(eventId, docId) {
    await pool.execute(
      "INSERT INTO eventdocuments (event_id, document_id) VALUES (?, ?)",
      [eventId, docId]
    );
  },

  // Notes and Comments
  async addNote(userId, docId, content, isPrivate = false) {
    const [result] = await pool.execute(
      "INSERT INTO notes (user_id, document_id, content, is_private) VALUES (?, ?, ?, ?)",
      [userId, docId, content, isPrivate ? 1 : 0]
    );
    return result.insertId;
  },

  async shareNote(noteId, recipientId) {
    await pool.execute(
      "INSERT INTO noterecipients (note_id, recipient_id, status) VALUES (?, ?, ?)",
      [noteId, recipientId, "delivered"]
    );
  },

  async markNoteAsRead(noteId, recipientId) {
    await pool.execute(
      "UPDATE noterecipients SET status = ?, read_at = CURRENT_TIMESTAMP WHERE note_id = ? AND recipient_id = ?",
      ["read", noteId, recipientId]
    );
  },

  // Organization Management
  async createOrganization(name, settings = {}) {
    const [result] = await pool.execute(
      "INSERT INTO organizations (name, settings) VALUES (?, ?)",
      [name, JSON.stringify(settings)]
    );
    return result.insertId;
  },

  async updateOrganizationSettings(orgId, settings) {
    await pool.execute("UPDATE organizations SET settings = ? WHERE id = ?", [
      JSON.stringify(settings),
      orgId,
    ]);
  },

  // Audit Trail
  async addAuditRecord(orgId, userId, actionType, docId, details, ipAddress) {
    await pool.execute(
      "INSERT INTO audittrail (organization_id, user_id, action_type, document_id, details, ip_address) VALUES (?, ?, ?, ?, ?, ?)",
      [orgId, userId, actionType, docId, details, ipAddress]
    );
  },

  async getDocumentAuditTrail(docId) {
    const [records] = await pool.execute(
      "SELECT a.action_type, a.details, a.created_at, u.first_name, u.last_name FROM audittrail a JOIN users u ON a.user_id = u.id WHERE a.document_id = ? ORDER BY a.created_at DESC",
      [docId]
    );
    return records;
  },
};

//Middlewares
// token cleanup on server startup
const cleanupExpiredTokens = async () => {
  try {
    await pool.execute("DELETE FROM refresh_tokens WHERE expires_at < NOW()");
    console.log("Expired tokens cleaned up");
  } catch (error) {
    console.error("Error cleaning up tokens:", error);
  }
};

function getRandomColor() {
  const letters = "0123456789ABCDEF";
  let color = "#";
  for (let i = 0; i < 6; i++) {
    color += letters[Math.floor(Math.random() * 16)];
  }
  return color;
}

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) {
    return res.status(401).json({ error: "Access token required" });
  }

  try {
    const decoded = jwt.verify(token, process.env.ACCESS_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: "Invalid token" });
  }
};

// Create invitation link with encrypted data
const generateInvitationToken = (data) => {
  // Only include necessary fields and set expiration
  const tokenData = {
    email: data.email,
    role: data.role,
    department: data.department,
    orgId: data.orgId,
    exp: Math.floor(Date.now() / 1000) + 7 * 24 * 60 * 60, // 7 days expiration
  };

  return jwt.sign(tokenData, ENCRYPTION_KEY);
};

// ==================== HELPER FUNCTIONS ====================

// Helper function to calculate folder path
async function calculateFolderPath(categoryId, parentCategoryId, connection) {
  const db = connection || pool;

  if (!parentCategoryId) {
    return categoryId.toString();
  }

  const query = `
    SELECT folder_path FROM template_categories
    WHERE category_id = ?
  `;

  const [results] = await db.execute(query, [parentCategoryId]);

  if (results.length === 0 || !results[0].folder_path) {
    return categoryId.toString();
  }

  return `${results[0].folder_path}/${categoryId}`;
}

// Helper function to build folder path for a category
function buildFolderPath(category, allCategories) {
  if (!category.parent_category_id) {
    return category.category_id.toString();
  }

  const parentIds = [];
  let currentCategory = category;

  // Build path by traversing up the hierarchy
  while (currentCategory.parent_category_id) {
    parentIds.unshift(currentCategory.category_id);
    const nextParent = allCategories.find(
      (c) => c.category_id === currentCategory.parent_category_id
    );
    if (!nextParent) break;
    currentCategory = nextParent;
  }

  // Add the root parent
  parentIds.unshift(currentCategory.category_id);

  return parentIds.join("/");
}

// Check for circular references
async function checkCircularReference(categoryId, parentId) {
  // Get all ancestors of the potential parent
  const ancestors = await getCategoryAncestors(parentId);
  // If the category ID is in the ancestors, it would create a circular reference
  return ancestors.some(
    (ancestor) => ancestor.category_id.toString() === categoryId.toString()
  );
}

// Get all ancestors of a category
async function getCategoryAncestors(categoryId) {
  const ancestors = [];
  let currentId = categoryId;

  while (currentId) {
    const query = `
      SELECT parent_category_id FROM template_categories
      WHERE category_id = ?
    `;

    const [results] = await pool.execute(query, [currentId]);

    if (results.length === 0 || !results[0].parent_category_id) {
      break;
    }

    currentId = results[0].parent_category_id;
    ancestors.push({ category_id: currentId });
  }

  return ancestors;
}

// Update paths of all child categories when a parent's path changes
async function updateChildrenPaths(parentId, connection) {
  const db = connection || pool;

  // Get direct children
  const childrenQuery = `
    SELECT category_id, parent_category_id FROM template_categories
    WHERE parent_category_id = ?
  `;

  const [children] = await db.execute(childrenQuery, [parentId]);

  for (const child of children) {
    // Calculate new path for this child
    const newPath = await calculateFolderPath(
      child.category_id,
      child.parent_category_id,
      db
    );

    // Update the child's path
    const updateQuery = `
      UPDATE template_categories
      SET folder_path = ?
      WHERE category_id = ?
    `;

    await db.execute(updateQuery, [newPath, child.category_id]);

    // Recursively update all descendants
    await updateChildrenPaths(child.category_id, db);
  }
}

// ========================= API ROUTES ========================

// Create Organization
app.post("/api/organization/register", async (req, res) => {
  try {
    const { name, settings } = req.body;
    const orgId = await dbOps.createOrganization(name, settings);
    res
      .status(201)
      .json({ id: orgId, message: "Organization registered successfully" });
  } catch (error) {
    console.error("Registration error:", error);
    res.status(500).json({ error: "Registration failed" });
  }
});

// User routes
app.post("/api/users/register", async (req, res) => {
  try {
    const { orgId, email, password, firstName, lastName, role } = req.body;
    const department = null;
    const template_approver = "no";
    const userId = await dbOps.registerUser(
      orgId,
      email,
      password,
      firstName,
      lastName,
      role,
      department,
      template_approver
    );
    res
      .status(201)
      .json({ id: userId, message: "User registered successfully" });
  } catch (error) {
    console.error("Registration error:", error);
    res.status(500).json({ error: "Registration failed" });
  }
});

// Verify invitation token endpoint
app.get("/api/invitations/verify/:token", async (req, res) => {
  try {
    const { token } = req.params;
    const invitation = await dbOps.checkInvitation(token);

    if (!invitation) {
      return res.status(404).json({ error: "Invalid or expired invitation" });
    }

    // Return relevant invitation data (excluding sensitive info)
    res.json({
      email: invitation.email,
      role: invitation.role,
      department: invitation.department,
      orgId: invitation.orgId,
    });
  } catch (error) {
    console.error("Error verifying invitation:", error);
    res.status(500).json({ error: "Failed to verify invitation" });
  }
});

// Register invited user endpoint
app.post("/api/invitations/register", async (req, res) => {
  try {
    const { token, firstName, lastName, password } = req.body;

    if (!token || !firstName || !lastName || !password) {
      return res.status(400).json({ error: "All fields are required" });
    }

    // Verify and decode the invitation token
    const invitation = await dbOps.checkInvitation(token);

    if (!invitation) {
      return res.status(404).json({ error: "Invalid or expired invitation" });
    }

    // Register the invited user
    const userData = await dbOps.registerInvitedUser(
      invitation.orgId,
      invitation.email,
      password,
      firstName,
      lastName,
      invitation.role || null,
      invitation.department || null
    );

    res.status(201).json({
      user: userData,
      message: "Registration successful",
    });
  } catch (error) {
    console.error("Error registering invited user:", error);
    res.status(500).json({ error: "Failed to register user" });
  }
});

app.post("/api/users/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await dbOps.loginUser(email);

    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    // In production, generate JWT token here
    const userData = { ...user };
    delete userData.password_hash;

    // Generate tokens
    const accessToken = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.ACCESS_SECRET,
      { expiresIn: "7d" }
    );

    const refreshToken = jwt.sign(
      { userId: user.id },
      process.env.REFRESH_SECRET,
      { expiresIn: "7d" }
    );

    // Store refresh token in database
    await pool.execute(
      "INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES (?, ?, ?)",
      [user.id, refreshToken, new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)]
    );

    // Return both tokens and user data
    res.json({
      accessToken,
      refreshToken,
      user: userData,
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Login failed" });
  }
});

// Password verification endpoint
app.post("/api/verify-password", authenticateToken, async (req, res) => {
  try {
    const { userId, password } = req.body;

    // 1. Get the user from MySQL database
    const [users] = await pool.query("SELECT * FROM users WHERE id = ?", [
      userId,
    ]);

    if (users.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = users[0];

    // 2. Verify the password
    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res
        .status(401)
        .json({ verified: false, error: "Incorrect password" });
    }

    // 3. If successful
    res.json({ verified: true });
  } catch (error) {
    console.error("Password verification error:", error);
    res.status(500).json({ error: "Password verification failed" });
  }
});

// Add this route to get current user data
app.get("/api/users/me", authenticateToken, async (req, res) => {
  try {
    const [user] = await pool.execute(
      "SELECT id, email, first_name, last_name, role, template_approver, organization_id FROM users WHERE id = ?",
      [req.user.userId]
    );

    if (!user.length) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json({
      id: user[0].id,
      email: user[0].email,
      firstName: user[0].first_name,
      lastName: user[0].last_name,
      role: user[0].role,
      orgId: user[0].organization_id,
      template_approver: user[0].template_approver,
    });
  } catch (error) {
    console.error("Error fetching user:", error);
    res.status(500).json({ error: "Failed to fetch user data" });
  }
});

// Add this route to handle logouts
app.post("/api/auth/logout", async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ error: "Refresh token required" });
    }

    // Delete the refresh token from database
    await pool.execute("DELETE FROM refresh_tokens WHERE token = ?", [
      refreshToken,
    ]);

    res.json({ message: "Logged out successfully" });
  } catch (error) {
    console.error("Logout error:", error);
    res.status(500).json({ error: "Logout failed" });
  }
});

app.post("/api/auth/refresh", async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(401).json({ error: "Refresh token required" });
    }

    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.REFRESH_SECRET);

    // Check if refresh token exists in DB
    const [validToken] = await pool.execute(
      "SELECT * FROM refresh_tokens WHERE token = ? AND user_id = ? AND expires_at > NOW()",
      [refreshToken, decoded.userId]
    );

    if (!validToken.length) {
      return res.status(401).json({ error: "Invalid refresh token" });
    }

    // Get user data
    const [user] = await pool.execute(
      "SELECT id, email FROM users WHERE id = ?",
      [decoded.userId]
    );

    // Generate new access token
    const newAccessToken = jwt.sign(
      { userId: user[0].id, email: user[0].email },
      process.env.ACCESS_SECRET,
      { expiresIn: "15m" }
    );

    res.json({ accessToken: newAccessToken });
  } catch (error) {
    res.status(401).json({ error: "Token refresh failed" });
  }
});

// Routes for Dashboard Get requests
//Route Get Users
app.get("/api/org_members/:userId", authenticateToken, async (req, res) => {
  try {
    const users = await dbOps.listOrganizationUsers(req.params.userId);

    // Remove sensitive data
    const sanitizedUsers = users.map((user) => {
      const { password_hash, ...userData } = user;
      return userData;
    });

    res.json(sanitizedUsers);
  } catch (error) {
    console.error("Error fetching team members:", error);
    res.status(500).json({ error: "Failed to fetch team members" });
  }
});

//Route Get Invited Users
app.get("/api/invited_users/:userId", authenticateToken, async (req, res) => {
  try {
    const users = await dbOps.listInvitedUsers(req.params.userId);

    res.json(users);
  } catch (error) {
    console.error("Error fetching invited members:", error);
    res.status(500).json({ error: "Failed to fetch invited members" });
  }
});

//Route Get Documents
app.get("/api/all-docs", authenticateToken, async (req, res) => {
  try {
    const docs = await dbOps.getAllDocuments();
    res.json(docs);
  } catch (error) {
    console.error("Error fetching documents:", error);
    res.status(500).json({ error: "Failed to fetch documents" });
  }
});

app.get("/api/my-docs/:userId", authenticateToken, async (req, res) => {
  try {
    const docs = await dbOps.getUserAccessibleDocuments(req.params.userId);
    res.json(docs);
  } catch (error) {
    console.error("Error fetching documents:", error);
    res.status(500).json({ error: "Failed to fetch documents" });
  }
});

//Route Get Tasks
app.get("/api/tasks/:userId", authenticateToken, async (req, res) => {
  try {
    const [tasks] = await pool.execute(
      `SELECT t.* FROM tasks t 
       JOIN taskassignments ta ON t.id = ta.task_id 
       WHERE ta.assigned_to = ? AND ta.status != 'completed'`,
      [req.params.userId]
    );
    res.json(tasks);
  } catch (error) {
    console.error("Error fetching tasks:", error);
    res.status(500).json({ error: "Failed to fetch tasks" });
  }
});

/* app.get('/api/notifications/:userId', authenticateToken, async (req, res) => {
  try {
    const [notifications] = await pool.execute(
      `SELECT * FROM notifications 
       WHERE user_id = ? AND status = 'unread' 
       ORDER BY created_at DESC LIMIT 10`,
      [req.params.userId]
    );
    res.json(notifications);
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
}); */

//Route Get Events
app.get("/api/calendar-events/:userId", authenticateToken, async (req, res) => {
  try {
    const events = await dbOps.getEvents(req.params.userId);
    res.json(events);
  } catch (error) {
    console.error("Error fetching calendar events:", error);
    res.status(500).json({ error: "Failed to fetch calendar events" });
  }
});

//Route Get Audit Trail
app.get("/api/activity-log/:userId", authenticateToken, async (req, res) => {
  try {
    const [activities] = await pool.execute(
      `SELECT a.* FROM audittrail a
       WHERE a.user_id = ?
       ORDER BY a.created_at DESC LIMIT 20`,
      [req.params.userId]
    );
    res.json(activities);
  } catch (error) {
    console.error("Error fetching activity log:", error);
    res.status(500).json({ error: "Failed to fetch activity log" });
  }
});

// ==================== TEMPLATES ROUTES ====================

//Route Get Templates
app.get("/api/templates/:userId", authenticateToken, async (req, res) => {
  try {
    // Assuming templates are organization-wide
    const templates = await dbOps.getTemplates(req.params.userId);
    res.json(templates);
  } catch (error) {
    console.error("Error fetching templates:", error);
    res.status(500).json({ error: "Failed to fetch templates" });
  }
});

// Get a specific template by ID
app.get(
  "/api/get_template/:templateId",
  authenticateToken,
  async (req, res) => {
    try {
      const templateId = req.params.templateId;

      const [templates] = await pool.execute(
        "SELECT * FROM templates WHERE id = ?",
        [templateId]
      );

      if (templates.length === 0) {
        return res.status(404).json({ error: "Template not found" });
      }

      res.json(templates[0]);
    } catch (error) {
      console.error("Error fetching template:", error);
      res.status(500).json({ error: "Failed to fetch template" });
    }
  }
);

app.post("/api/newtemplate", authenticateToken, async (req, res) => {
  try {
    const {
      name,
      description,
      created_by,
      organization_id,
      category_id,
      approvers,
      impact,
      locked_elements,
      allowAttachments,
      includeTableOfContents,
      content,
      notes,
      status,
      template_approvers,
    } = req.body;

    if (!name || !created_by || !organization_id) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields",
      });
    }

    // Initialize category_id as null if not provided
    let finalCategoryId = category_id || null;

    // If category_id is provided, verify it exists and belongs to the organization
    if (finalCategoryId) {
      const categoryCheckQuery = `
        SELECT category_id FROM template_categories
        WHERE category_id = ? AND organization_id = ?
      `;

      const [categories] = await pool.execute(categoryCheckQuery, [
        finalCategoryId,
        organization_id,
      ]);

      if (categories.length === 0) {
        return res.status(404).json({
          success: false,
          error: "Category not found",
        });
      }
    }

    const templateId = uuidv4();

    // Create template structure with additional fields
    const templateStructure = {
      locked_elements: locked_elements || {},
      allowAttachments: allowAttachments || false,
      includeTableOfContents: includeTableOfContents || false,
    };

    await pool.execute(
      `INSERT INTO templates 
      (id, organization_id, name, description, content, template_structure, required_approvers, impact, notes, template_approvers, comments, created_by, category_id, created_at, updated_at, status) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW(), ?)`,
      [
        templateId,
        organization_id,
        name,
        description || null,
        content ? JSON.stringify(content) : null,
        JSON.stringify(templateStructure),
        approvers ? JSON.stringify(approvers) : "[]",
        impact ? JSON.stringify(impact) : null,
        notes || null,
        template_approvers ? JSON.stringify(template_approvers) : null,
        content ? JSON.stringify(content) : null,
        created_by,
        finalCategoryId,
        status || "draft",
      ]
    );

    return res.status(201).json({
      success: true,
      message: "Template created successfully",
      templateId: templateId,
    });
  } catch (error) {
    console.error("Error creating template:", error);
    return res.status(500).json({
      success: false,
      message: "Server error while creating template",
    });
  }
});

app.put(
  "/api/update_template/:templateId",
  authenticateToken,
  async (req, res) => {
    try {
      const templateId = req.params.templateId;
      const {
        name,
        description,
        category_id,
        content,
        notes,
        template_approvers,
        status,
        approvers,
        impact,
        locked_elements,
        allowAttachments,
        includeTableOfContents,
      } = req.body;

      // Validate template ID
      if (!templateId) {
        return res.status(400).json({
          success: false,
          error: "Invalid template ID",
        });
      }

      // Build query parts
      let updateParts = [];
      let params = [];

      // Handle basic fields
      if (name !== undefined) {
        updateParts.push("name = ?");
        params.push(name);
      }

      if (description !== undefined) {
        updateParts.push("description = ?");
        params.push(description);
      }

      if (category_id !== undefined) {
        updateParts.push("category_id = ?");
        params.push(category_id);
      }

      if (notes !== undefined) {
        updateParts.push("notes = ?");
        params.push(notes);
      }

      // Handle content update
      if (content !== undefined) {
        updateParts.push("content = ?");
        params.push(content ? JSON.stringify(content) : null);
      }

      if (content !== undefined) {
        updateParts.push("comments = ?");
        params.push(content ? JSON.stringify(content) : null);
      }

      // Handle template structure updates
      let templateStructureUpdates = {};

      if (locked_elements !== undefined) {
        templateStructureUpdates.locked_elements = locked_elements;
      }

      if (allowAttachments !== undefined) {
        templateStructureUpdates.allowAttachments = allowAttachments;
      }

      if (includeTableOfContents !== undefined) {
        templateStructureUpdates.includeTableOfContents =
          includeTableOfContents;
      }

      // Only fetch current template structure if we have updates to merge
      if (Object.keys(templateStructureUpdates).length > 0) {
        const [currentTemplate] = await pool.execute(
          "SELECT template_structure FROM templates WHERE id = ?",
          [templateId]
        );

        let currentStructure = {};
        if (
          currentTemplate.length > 0 &&
          currentTemplate[0].template_structure
        ) {
          try {
            currentStructure = JSON.parse(
              currentTemplate[0].template_structure
            );
          } catch (e) {
            console.error("Error parsing template structure:", e);
            currentStructure = {};
          }
        }

        // Merge updates
        const updatedStructure = {
          ...currentStructure,
          ...templateStructureUpdates,
        };
        updateParts.push("template_structure = ?");
        params.push(JSON.stringify(updatedStructure));
      }

      // Handle approvers update
      if (approvers !== undefined) {
        updateParts.push("required_approvers = ?");
        params.push(approvers ? JSON.stringify(approvers) : "[]");
      }

      // Handle impact update
      if (impact !== undefined) {
        updateParts.push("impact = ?");
        params.push(impact ? JSON.stringify(impact) : null);
      }

      // Handle status
      if (status !== undefined) {
        updateParts.push("status = ?");
        params.push(status || "draft");
      }

      // Handle approvers update
      if (template_approvers !== undefined) {
        updateParts.push("template_approvers = ?");
        params.push(
          template_approvers ? JSON.stringify(template_approvers) : "[]"
        );
      }

      // Add updated_at timestamp
      updateParts.push("updated_at = CURRENT_TIMESTAMP");

      // Check if we have any fields to update
      if (updateParts.length === 0) {
        return res.status(400).json({
          success: false,
          error: "No valid fields to update",
        });
      }

      // Add template ID to params for WHERE clause
      params.push(templateId);

      // Execute the query
      const [result] = await pool.execute(
        `UPDATE templates SET ${updateParts.join(", ")} WHERE id = ?`,
        params
      );

      // Check if any rows were affected
      if (result.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          error: "Template not found or no changes made",
        });
      }

      res.json({
        success: true,
        message: "Template updated successfully",
        templateId: templateId,
      });
    } catch (error) {
      console.error("Error updating template:", error);
      res.status(500).json({
        success: false,
        error: "Failed to update template",
        details:
          process.env.NODE_ENV === "development" ? error.message : undefined,
      });
    }
  }
);

app.put(
  "/api/update_content/:templateId",
  authenticateToken,
  async (req, res) => {
    try {
      const templateId = req.params.templateId;
      const { comments } = req.body;

      // Validate template ID and comments
      if (!templateId) {
        return res.status(400).json({
          success: false,
          error: "Invalid template ID",
        });
      }

      if (comments === undefined) {
        return res.status(400).json({
          success: false,
          error: "Comments data is required",
        });
      }

      // Also update the content field if the comments contain content
      let commentsData;
      try {
        commentsData = JSON.parse(comments);
      } catch (e) {
        commentsData = { content: "", comments: [] };
      }

      // If we have content in the comments data, update both fields
      if (commentsData && commentsData.content) {
        const [result] = await pool.execute(
          "UPDATE templates SET comments = ?, content = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
          [comments, comments, templateId]
        );

        // Check if any rows were affected
        if (result.affectedRows === 0) {
          return res.status(404).json({
            success: false,
            error: "Template not found or no changes made",
          });
        }
      } else {
        // Otherwise just update comments
        const [result] = await pool.execute(
          "UPDATE templates SET comments = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
          [comments, templateId]
        );

        // Check if any rows were affected
        if (result.affectedRows === 0) {
          return res.status(404).json({
            success: false,
            error: "Template not found or no changes made",
          });
        }
      }

      res.json({
        success: true,
        message: "Comments updated successfully",
        templateId: templateId,
      });
    } catch (error) {
      console.error("Error updating comments:", error);
      res.status(500).json({
        success: false,
        error: "Failed to update comments",
        details:
          process.env.NODE_ENV === "development" ? error.message : undefined,
      });
    }
  }
);

// ==================== DEPARTMENTS ROUTES ====================

// Route Get Departments
app.get("/api/departments/:orgId", authenticateToken, async (req, res) => {
  try {
    const { orgId } = req.params;
    const [rows] = await pool.query(
      "SELECT * FROM departments WHERE organization_id = ? ORDER BY name",
      [orgId]
    );
    res.json(rows);
  } catch (error) {
    console.error("Error fetching departments:", error);
    res.status(500).json({ error: "Failed to fetch departments" });
  }
});

// Add new department
app.post("/api/add_department/:orgId", authenticateToken, async (req, res) => {
  try {
    const { name, manager } = req.body;
    const { orgId } = req.params;
    const status = "active";

    // Check if department already exists
    const [existing] = await pool.query(
      "SELECT id FROM departments WHERE organization_id = ? AND name = ?",
      [orgId, name]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: "Department already exists" });
    }

    // Insert new department
    await pool.query(
      "INSERT INTO departments (organization_id, name, manager, status) VALUES (?, ?, ?, ?)",
      [orgId, name, manager, status]
    );

    // Return success without the created object (since we'll refetch)
    res.status(201).json({ success: true });
  } catch (error) {
    console.error("Error adding department:", error);
    res.status(500).json({ error: "Failed to add department" });
  }
});

// Edit department
app.put("/api/edit_department/:deptId", authenticateToken, async (req, res) => {
  try {
    const { name, manager, status, orgId } = req.body;
    const { deptId } = req.params;

    // Validate input
    if (!name) {
      return res.status(400).json({ error: "Name are required" });
    }

    // Update existing department
    await pool.query(
      "UPDATE departments SET name = ?, manager = ?, status = ? WHERE id = ? AND organization_id = ?",
      [name, manager, status, deptId, orgId]
    );

    // Return success
    res.status(200).json({ success: true });
  } catch (error) {
    console.error("Error updating department:", error);
    res.status(500).json({ error: "Failed to update department" });
  }
});

// ==================== TEMPLATE CATEGORIES ROUTES ====================

// Get all template categories for an organization
app.get(
  "/api/template_categories/:orgId",
  authenticateToken,
  async (req, res) => {
    try {
      const organizationId = req.params.orgId;

      const query = `
      SELECT category_id, organization_id, category_name, category_prefix, folder_path, parent_category_id
      FROM template_categories
      WHERE organization_id = ?
      ORDER BY category_name
    `;

      const [categories] = await pool.execute(query, [organizationId]);

      // Calculate folder paths based on parent-child relationships
      categories.forEach((category) => {
        if (!category.folder_path) {
          category.folder_path = buildFolderPath(category, categories);
        }
      });

      res.json(categories);
    } catch (error) {
      console.error("Error fetching template categories:", error);
      res.status(500).json({ error: "Failed to fetch template categories" });
    }
  }
);

// Create a new template category
app.post("/api/add_category/:orgId", authenticateToken, async (req, res) => {
  try {
    const { category_name, category_prefix, parent_category_id } = req.body;
    const organization_id = parseInt(req.params.orgId);

    if (!category_name) {
      return res.status(400).json({ error: "Category name is required" });
    }

    // Start transaction
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // Insert new category
      const insertQuery = `
        INSERT INTO template_categories 
        (organization_id, category_name, category_prefix, parent_category_id, folder_path)
        VALUES (?, ?, ?, ?, '')
      `;

      const [result] = await connection.execute(insertQuery, [
        organization_id,
        category_name,
        category_prefix,
        parent_category_id || null,
      ]);

      const category_id = result.insertId;

      // Calculate and update folder path
      const folder_path = await calculateFolderPath(
        category_id,
        parent_category_id,
        connection
      );

      const updatePathQuery = `
        UPDATE template_categories
        SET folder_path = ?
        WHERE category_id = ?
      `;

      await connection.execute(updatePathQuery, [folder_path, category_id]);

      // Commit transaction
      await connection.commit();
      connection.release();

      res.status(201).json({
        category_id,
        organization_id,
        category_name,
        category_prefix,
        parent_category_id: parent_category_id || null,
        folder_path,
      });
    } catch (error) {
      // Rollback transaction on error
      await connection.rollback();
      connection.release();
      throw error;
    }
  } catch (error) {
    console.error("Error creating template category:", error);
    res.status(500).json({ error: "Failed to create template category" });
  }
});

// Update a template category
app.put("/api/update_category/:orgId", authenticateToken, async (req, res) => {
  try {
    const { categoryId, category_name, category_prefix, parent_category_id } =
      req.body;
    const organization_id = req.params.orgId;

    if (!category_name) {
      return res.status(400).json({ error: "Category name is required" });
    }

    // Check if category exists and belongs to the organization
    const checkQuery = `
      SELECT category_id FROM template_categories 
      WHERE category_id = ? AND organization_id = ?
    `;

    const [existingCategories] = await pool.execute(checkQuery, [
      categoryId,
      organization_id,
    ]);

    if (existingCategories.length === 0) {
      return res.status(404).json({ error: "Category not found" });
    }

    // Prevent circular reference - a category cannot be its own parent
    if (
      parent_category_id &&
      parent_category_id.toString() === categoryId.toString()
    ) {
      return res
        .status(400)
        .json({ error: "A category cannot be its own parent" });
    }

    // Check for circular references in the hierarchy
    if (parent_category_id) {
      const isCircular = await checkCircularReference(
        categoryId,
        parent_category_id
      );
      if (isCircular) {
        return res
          .status(400)
          .json({ error: "Circular reference detected in category hierarchy" });
      }
    }

    // Start transaction
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // Update the category
      const updateQuery = `
        UPDATE template_categories
        SET category_name = ?, category_prefix = ?, parent_category_id = ?
        WHERE category_id = ? AND organization_id = ?
      `;

      await connection.execute(updateQuery, [
        category_name,
        category_prefix,
        parent_category_id || null,
        categoryId,
        organization_id,
      ]);

      // Calculate and update folder path
      const folder_path = await calculateFolderPath(
        categoryId,
        parent_category_id,
        connection
      );

      const updatePathQuery = `
        UPDATE template_categories
        SET folder_path = ?
        WHERE category_id = ?
      `;

      await connection.execute(updatePathQuery, [folder_path, categoryId]);

      // Update paths of all child categories
      await updateChildrenPaths(categoryId, connection);

      // Commit transaction
      await connection.commit();
      connection.release();

      res.json({
        category_id: parseInt(categoryId),
        organization_id,
        category_name,
        category_prefix,
        parent_category_id: parent_category_id || null,
        folder_path,
      });
    } catch (error) {
      // Rollback transaction on error
      await connection.rollback();
      connection.release();
      throw error;
    }
  } catch (error) {
    console.error("Error updating template category:", error);
    res.status(500).json({ error: "Failed to update template category" });
  }
});

// Delete a template category
app.delete("/api/delete_category", authenticateToken, async (req, res) => {
  try {
    const { categoryId, organization_id } = req.body;
    console.log(organization_id, categoryId);

    // Check if category exists and belongs to the organization
    const checkQuery = `
      SELECT category_id FROM template_categories 
      WHERE category_id = ? AND organization_id = ?
    `;

    const [existingCategories] = await pool.execute(checkQuery, [
      categoryId,
      organization_id,
    ]);

    if (existingCategories.length === 0) {
      return res.status(404).json({ error: "Category not found" });
    }

    // Check if category has templates
    const templateCheckQuery = `
      SELECT id FROM templates 
      WHERE category_id = ? AND organization_id = ?
      LIMIT 1
    `;

    const [existingTemplates] = await pool.execute(templateCheckQuery, [
      categoryId,
      organization_id,
    ]);

    if (existingTemplates.length > 0) {
      return res.status(400).json({
        error:
          "Cannot delete category that contains templates. Move or delete the templates first.",
      });
    }

    // Check if category has subcategories
    const subcategoryCheckQuery = `
      SELECT category_id FROM template_categories 
      WHERE parent_category_id = ?
      LIMIT 1
    `;

    const [existingSubcategories] = await pool.execute(subcategoryCheckQuery, [
      categoryId,
    ]);

    if (existingSubcategories.length > 0) {
      return res.status(400).json({
        error:
          "Cannot delete category that has subcategories. Delete or move subcategories first.",
      });
    }

    // Delete the category
    const deleteQuery = `
      DELETE FROM template_categories
      WHERE category_id = ? AND organization_id = ?
    `;

    await pool.execute(deleteQuery, [categoryId, organization_id]);

    res.json({ message: "Category deleted successfully" });
  } catch (error) {
    console.error("Error deleting template category:", error);
    res.status(500).json({ error: "Failed to delete template category" });
  }
});

// Invite new team member
app.post(
  "/api/invite_org_member/:orgId",
  authenticateToken,
  async (req, res) => {
    try {
      const { email, role, department, message } = req.body;
      console.log(req.body);
      // Validation
      if (!email) {
        return res.status(400).json({ error: "All fields are required" });
      }

      // Check if user already exists
      const [existingUsers] = await pool.execute(
        "SELECT id FROM invited_users WHERE email = ?",
        [email]
      );

      if (existingUsers.length > 0) {
        return res
          .status(409)
          .json({ error: "User with this email already exists" });
      }

      const { orgId } = req.params;
      const status = "invited";

      const userId = await dbOps.inviteUser(
        orgId,
        email,
        role,
        department,
        message,
        status
      );

      // Get organization name
      const [orgs] = await pool.execute(
        "SELECT name FROM organizations WHERE id = ?",
        [orgId]
      );

      if (orgs.length === 0) {
        return res.status(404).json({ error: "Organization not found" });
      }

      const orgName = orgs[0].name;

      // Generate invitation token with encrypted data
      const invitationToken = generateInvitationToken({
        email,
        role,
        department,
        orgId,
      });

      // Create invitation link
      const invitationLink = `${
        process.env.CLIENT_URL || "http://localhost:3001"
      }/join/${invitationToken}`;

      // Send email invitation
      /* await transporter.sendMail({
      from: process.env.EMAIL_FROM || 'noreply@example.com',
      to: email,
      subject: `Invitation to join ${orgName}`,
      html: `
        <h1>You've been invited to join ${orgName}</h1>
        <p>${message || 'Please join our organization by clicking the link below:'}</p>
        <p><a href="${invitationLink}">Click here to accept the invitation</a></p>
        <p>This invitation link will expire in 7 days.</p>
      `
    }); */

      res.status(201).json({
        id: userId,
        link: invitationLink,
        message: "Team member invited successfully",
      });
    } catch (error) {
      console.error("Error inviting team member:", error);
      res.status(500).json({ error: "Failed to add team member" });
    }
  }
);

// Remove Invited User
app.delete(
  "/api/cancel_invite/:userId",
  authenticateToken,
  async (req, res) => {
    try {
      const { userId } = req.params;

      // Soft delete - Update status to 'inactive'
      await pool.execute(
        "DELETE FROM invited_users WHERE status = ? AND id = ?",
        ["invited", userId]
      );

      res.json({ message: "Invited user removed successfully" });
    } catch (error) {
      console.error("Error removing invited user:", error);
      res.status(500).json({ error: "Failed to remove team member" });
    }
  }
);

// Approve Invited User
app.post("/api/approve_invite/:userId", authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;

    // 2. Fix the query to get a single row and destructure properly
    const [rows] = await pool.execute(
      "SELECT * FROM invited_users WHERE status = ? AND id = ?",
      ["pending", userId]
    );

    // 3. Check if user exists
    if (rows.length === 0) {
      return res
        .status(404)
        .json({ error: "Invited user not found or already approved" });
    }

    const userData = rows[0];

    // 4. Fix variable naming conflict (userId is already declared)
    const template_approver = "no";
    const newUserId = await dbOps.registerUser(
      userData.organization_id,
      userData.email,
      userData.password_hash,
      userData.first_name,
      userData.last_name,
      userData.role,
      userData.department,
      template_approver
    );

    // 5. Delete the invitation after successful registration
    await pool.execute("DELETE FROM invited_users WHERE id = ?", [userId]);

    res.json({
      message: "Invited user approved successfully",
      userId: newUserId,
    });
  } catch (error) {
    console.error("Error approving invited user:", error);
    res.status(500).json({ error: "Failed to approve team member" });
  }
});

// Reject Invited User
app.delete(
  "/api/reject_invite/:userId",
  authenticateToken,
  async (req, res) => {
    try {
      const { userId } = req.params;

      // Soft delete - Update status to 'inactive'
      await pool.execute(
        "DELETE FROM invited_users WHERE status = ? AND id = ?",
        ["pending", userId]
      );

      res.json({ message: "Invited user removed successfully" });
    } catch (error) {
      console.error("Error removing invited user:", error);
      res.status(500).json({ error: "Failed to remove team member" });
    }
  }
);

// Add new team member
app.post("/api/add_org_member/:orgId", authenticateToken, async (req, res) => {
  try {
    const {
      email,
      password,
      firstName,
      lastName,
      role,
      department,
      template_approver,
    } = req.body;
    console.log(req.body);
    // Validation
    if (!firstName || !lastName || !email || !password) {
      return res.status(400).json({ error: "All fields are required" });
    }

    // Check if user already exists
    const [existingUsers] = await pool.execute(
      "SELECT id FROM users WHERE email = ?",
      [email]
    );

    if (existingUsers.length > 0) {
      return res
        .status(409)
        .json({ error: "User with this email already exists" });
    }

    const { orgId } = req.params;

    const userId = await dbOps.registerUser(
      orgId,
      email,
      password,
      firstName,
      lastName,
      role,
      department,
      template_approver
    );

    res.status(201).json({
      id: userId,
      message: "Team member added successfully",
    });
  } catch (error) {
    console.error("Error adding team member:", error);
    res.status(500).json({ error: "Failed to add team member" });
  }
});

// Edit team member
app.put("/api/edit_org_member/:userId", authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const {
      firstName,
      lastName,
      email,
      role,
      department,
      template_approver,
      status,
    } = req.body;

    // Validation
    if (!firstName || !lastName || !email || !status) {
      return res.status(400).json({ error: "Required fields missing" });
    }

    // Update user profile
    await dbOps.updateUserProfile(userId, {
      firstName,
      lastName,
      email,
      department,
      template_approver,
      status,
    });

    await dbOps.changeUserRole(userId, role);

    res.json({ message: "Team member updated successfully" });
  } catch (error) {
    console.error("Error updating team member:", error);
    res.status(500).json({ error: "Failed to update team member" });
  }
});

// Remove team member
app.delete(
  "/api/del_org_member/:userId",
  authenticateToken,
  async (req, res) => {
    try {
      const { userId } = req.params;

      // Don't allow self-deletion
      if (userId === req.user.id) {
        return res.status(400).json({ error: "Cannot remove yourself" });
      }

      // Soft delete - Update status to 'inactive'
      await pool.execute("UPDATE users SET status = ? WHERE id = ?", [
        "inactive",
        userId,
      ]);

      res.json({ message: "Team member removed successfully" });
    } catch (error) {
      console.error("Error removing team member:", error);
      res.status(500).json({ error: "Failed to remove team member" });
    }
  }
);

// Change team member password (admin only)
app.put("/team/:userId/password", authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const { password } = req.body;

    if (!password || password.length < 8) {
      return res
        .status(400)
        .json({ error: "Valid password required (min 8 characters)" });
    }

    // Check if user exists and belongs to same organization
    const [users] = await pool.execute(
      "SELECT u1.organization_id FROM users u1 JOIN users u2 ON u1.organization_id = u2.organization_id WHERE u1.id = ? AND u2.id = ?",
      [req.user.id, userId]
    );

    if (users.length === 0) {
      return res
        .status(404)
        .json({ error: "User not found or not in your organization" });
    }

    // Update password
    const passwordHash = await bcrypt.hash(password, 10);
    await pool.execute(
      "UPDATE users SET password_hash = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
      [passwordHash, userId]
    );

    // Add audit record (don't include the actual password in audit)
    await dbOps.addAuditRecord(
      users[0].organization_id,
      req.user.id,
      "password_reset",
      null,
      `Password reset for user ${userId}`,
      req.ip
    );

    res.json({ message: "Password updated successfully" });
  } catch (error) {
    console.error("Error updating password:", error);
    res.status(500).json({ error: "Failed to update password" });
  }
});

// Create a new document
app.post("/api/create-document", authenticateToken, async (req, res) => {
  const { title, template_id, content, tasks, participants } = req.body;
  console.log(content);

  const userId = req.user.userId;

  try {
    // Start transaction
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // 1. Get user's organization
      const [orgResults] = await connection.execute(
        "SELECT organization_id FROM users WHERE id = ?",
        [userId]
      );

      if (orgResults.length === 0) {
        throw new Error("User not found");
      }

      const orgId = orgResults[0].organization_id;

      // 2. Create the document
      const docId = uuidv4();
      await connection.execute(
        `INSERT INTO documents 
        (document_id, organization_id, title, template_id, created_by, status, content, elements) 
        VALUES (?, ?, ?, ?, ?, 'draft', ?, ?)`,
        [
          docId,
          orgId,
          title,
          template_id,
          userId,
          JSON.stringify(content),
          JSON.stringify({ comments: [], suggestedEdits: [] }),
        ]
      );

      // 3. Handle permissions - CRITICAL FIX HERE
      // First remove any duplicate creator entries from participants
      const filteredParticipants = participants.filter(
        (p) => p.user_id !== userId
      );

      // Then create permissions in one batch
      const permissionRecords = [
        [docId, userId, "author", userId, "active"], // Creator permission
        ...filteredParticipants.map((p) => [
          docId,
          p.user_id,
          p.role,
          userId,
          "active",
        ]),
      ];

      await connection.query(
        `INSERT INTO documentpermissions 
        (document_id, user_id, permission_type, assigned_by, status) 
        VALUES ?`,
        [permissionRecords]
      );

      // 4. Create tasks if any
      if (tasks && tasks.length > 0) {
        for (const task of tasks) {
          const taskId = uuidv4();
          await connection.execute(
            `INSERT INTO tasks 
            (id, organization_id, document_id, title, description, created_by, due_date, status) 
            VALUES (?, ?, ?, ?, ?, ?, ?,'not_started')`,
            [
              taskId,
              orgId,
              docId,
              task.title,
              task.description,
              task.created_by,
              task.due_date,
            ]
          );

          // Assign task to creator by default (can be reassigned later)
          await connection.execute(
            `INSERT INTO taskassignments 
            (task_id, assigned_to, assigned_by, status) 
            VALUES (?, ?, ?, 'pending')`,
            [taskId, userId, userId]
          );
        }
      }

      // Commit transaction
      await connection.commit();
      connection.release();

      res.status(201).json({
        success: true,
        document_id: docId,
        message: "Document created successfully",
      });
    } catch (error) {
      // Rollback transaction on error
      await connection.rollback();
      connection.release();
      throw error;
    }
  } catch (error) {
    console.error("Error creating document:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to create document",
    });
  }
});

// Update document status
app.put(
  "/api/update-document-status/:documentId",
  authenticateToken,
  async (req, res) => {
    const { documentId } = req.params;
    const { status } = req.body;
    const userId = req.user.userId;

    try {
      // Start transaction
      const connection = await pool.getConnection();
      await connection.beginTransaction();

      try {
        // 1. Verify user has permission to update this document
        const [permissionResults] = await connection.execute(
          `SELECT permission_type FROM documentpermissions 
         WHERE document_id = ? AND user_id = ? AND status = 'active'`,
          [documentId, userId]
        );

        if (permissionResults.length === 0) {
          throw new Error("You do not have permission to update this document");
        }

        const permissionType = permissionResults[0].permission_type;

        // 2. Validate status transition based on permission type
        const validTransitions = {
          author: ["in_review", "for_approval", "published"],
        };

        if (!validTransitions[permissionType]?.includes(status)) {
          throw new Error(
            `User with ${permissionType} role cannot set status to ${status}`
          );
        }

        // 3. Update document status
        await connection.execute(
          `UPDATE documents SET status = ?, updated_at = NOW()
         WHERE document_id = ?`,
          [status, documentId]
        );

        // Commit transaction
        await connection.commit();
        connection.release();

        res.status(200).json({
          success: true,
          message: `Document status updated to ${status} successfully`,
        });
      } catch (error) {
        // Rollback transaction on error
        await connection.rollback();
        connection.release();
        throw error;
      }
    } catch (error) {
      console.error("Error updating document status:", error);
      res.status(500).json({
        success: false,
        message: error.message || "Failed to update document status",
      });
    }
  }
);

app.get("/api/documents/:id", async (req, res) => {
  try {
    const docId = req.params.id;
    const document = await dbOps.getDocumentById(docId);

    if (!document) {
      return res.status(404).json({ error: "Document not found" });
    }

    res.json(document);
  } catch (error) {
    console.error("Document fetch error:", error);
    res.status(500).json({ error: "Failed to fetch document" });
  }
});

// Socket.io connection
io.on("connection", (socket) => {
  console.log(`New socket connection: 
    - Socket ID: ${socket.id}
    - Connection Timestamp: ${new Date().toISOString()}`);

  socket.on("joinDocument", async ({ docId, userId, userName }) => {
    socket.join(docId);
    console.log(`User joined document: 
      - Document ID: ${docId}
      - User ID: ${userId}
      - Username: ${userName}
      - Timestamp: ${new Date().toISOString()}`);

    try {
      // Fetch document content from database
      const [documents] = await pool.execute(
        "SELECT content, elements FROM documents WHERE document_id = ?",
        [docId]
      );

      if (documents.length > 0) {
        const documentData = documents[0];
        const content = JSON.parse(documentData.content || "{}");
        const elements = JSON.parse(documentData.elements || "{}");

        socket.emit("loadDocument", { content });
        socket.emit("loadDocElements", {
          comments: elements.comments || [],
          suggestedEdits: elements.suggestedEdits || [],
        });
      }
    } catch (error) {
      console.error("Error fetching document:", error);
    }
  });

  socket.on("textChange", async ({ docId, content }) => {
    try {
      // Update document content in database
      await pool.execute(
        "UPDATE documents SET content = ? WHERE document_id = ?",
        [JSON.stringify(content), docId]
      );

      io.to(docId).emit("updateDocument", { content });

      console.log(`Document content changed: 
        - Document ID: ${docId}
        - Content Length: ${JSON.stringify(content).length} characters
        - Timestamp: ${new Date().toISOString()}`);
    } catch (error) {
      console.error("Error updating document content:", error);
    }
  });

  socket.on("addDocElements", async (data) => {
    try {
      const { docId, comment, suggestededit } = data;

      // Fetch current elements
      const [documents] = await pool.execute(
        "SELECT elements FROM documents WHERE document_id = ?",
        [docId]
      );

      let currentElements =
        documents[0] && documents[0].elements
          ? JSON.parse(documents[0].elements)
          : { comments: [], suggestedEdits: [] };

      // Add new element
      if (comment) {
        currentElements.comments = currentElements.comments || [];
        currentElements.comments.push(comment);
      }

      if (suggestededit) {
        currentElements.suggestedEdits = currentElements.suggestedEdits || [];
        currentElements.suggestedEdits.push(suggestededit);
      }

      // Update elements in database
      await pool.execute(
        "UPDATE documents SET elements = ? WHERE document_id = ?",
        [JSON.stringify(currentElements), docId]
      );

      // Emit to all clients in the document
      if (comment) {
        io.to(docId).emit("receiveDocElements", { comment });
        console.log(`New comment added: 
          - Document ID: ${docId}
          - Comment ID: ${comment.id}
          - Author: ${comment.author}
          - Timestamp: ${new Date().toISOString()}`);
      }

      if (suggestededit) {
        io.to(docId).emit("receiveDocElements", { suggestededit });
        console.log(`New suggested edit added: 
          - Document ID: ${docId}
          - Suggested Edit ID: ${suggestededit.id}
          - Author: ${suggestededit.author}
          - Timestamp: ${new Date().toISOString()}`);
      }
    } catch (error) {
      console.error("Error adding document elements:", error);
    }
  });

  socket.on("removeComment", async ({ docId, commentId }) => {
    try {
      // Fetch current elements
      const [documents] = await pool.execute(
        "SELECT elements FROM documents WHERE document_id = ?",
        [docId]
      );

      let currentElements =
        documents[0] && documents[0].elements
          ? JSON.parse(documents[0].elements)
          : { comments: [], suggestedEdits: [] };

      // Remove comment
      const removedComments = currentElements.comments.filter(
        (comment) => comment.id === commentId
      );

      currentElements.comments = currentElements.comments.filter(
        (comment) => comment.id !== commentId
      );

      // Update elements in database
      await pool.execute(
        "UPDATE documents SET elements = ? WHERE document_id = ?",
        [JSON.stringify(currentElements), docId]
      );

      io.to(docId).emit("commentRemoved", { commentId });

      console.log(`Comment removed: 
        - Document ID: ${docId}
        - Comment ID: ${commentId}
        - Removed Comment Details: ${JSON.stringify(removedComments[0])}
        - Timestamp: ${new Date().toISOString()}`);
    } catch (error) {
      console.error("Error removing comment:", error);
    }
  });

  socket.on("removeSuggestedEdit", async ({ docId, suggestededitId }) => {
    try {
      // Fetch current elements
      const [documents] = await pool.execute(
        "SELECT elements FROM documents WHERE document_id = ?",
        [docId]
      );

      let currentElements =
        documents[0] && documents[0].elements
          ? JSON.parse(documents[0].elements)
          : { comments: [], suggestedEdits: [] };

      const removedEdits = currentElements.suggestedEdits.filter(
        (edit) => edit.id === suggestededitId
      );

      currentElements.suggestedEdits = currentElements.suggestedEdits.filter(
        (edit) => edit.id !== suggestededitId
      );

      // Update elements in database
      await pool.execute(
        "UPDATE documents SET elements = ? WHERE document_id = ?",
        [JSON.stringify(currentElements), docId]
      );

      io.to(docId).emit("suggestedEditRemoved", { suggestededitId });

      console.log(`Suggested edit removed: 
        - Document ID: ${docId}
        - Suggested Edit ID: ${suggestededitId}
        - Removed Edit Details: ${JSON.stringify(removedEdits[0])}
        - Timestamp: ${new Date().toISOString()}`);
    } catch (error) {
      console.error("Error removing Suggested edit:", error);
    }
  });

  socket.on("batchDeleteElements", async ({ docId, deletions }) => {
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();

      // 1. Fetch current document state
      const [documents] = await connection.execute(
        "SELECT elements FROM documents WHERE document_id = ?",
        [docId]
      );

      let currentElements = documents[0]?.elements
        ? JSON.parse(documents[0].elements)
        : { comments: [], suggestedEdits: [] };

      // 2. Process deletions
      const removalReport = {
        timestamp: new Date().toISOString(),
        docId,
        removedComments: [],
        removedEdits: [],
      };

      deletions.forEach(({ type, id }) => {
        if (type === "comment") {
          const comment = currentElements.comments.find((c) => c.id === id);
          if (comment) {
            removalReport.removedComments.push({
              id,
              user: comment.user,
              text: comment.text,
              timestamp: comment.timestamp,
            });
            currentElements.comments = currentElements.comments.filter(
              (c) => c.id !== id
            );
          }
        } else if (type === "suggestededit") {
          const edit = currentElements.suggestedEdits.find((e) => e.id === id);
          if (edit) {
            removalReport.removedEdits.push({
              id,
              user: edit.user,
              originalText: edit.selectedText,
              suggestedText: edit.text,
              timestamp: edit.timestamp,
            });
            currentElements.suggestedEdits =
              currentElements.suggestedEdits.filter((e) => e.id !== id);
          }
        }
      });

      // 3. Update database
      await connection.execute(
        "UPDATE documents SET elements = ? WHERE document_id = ?",
        [JSON.stringify(currentElements), docId]
      );

      await connection.commit();

      // 4. Notify clients and log
      removalReport.removedComments.forEach(({ id }) => {
        io.to(docId).emit("commentRemoved", { commentId: id });
      });

      removalReport.removedEdits.forEach(({ id }) => {
        io.to(docId).emit("suggestedEditRemoved", { suggestededitId: id });
      });

      console.log(`Batch deletion processed:
      - Document: ${docId}
      - Total Removals: ${deletions.length}
      - Comments Removed: ${removalReport.removedComments.length}
      - Edits Removed: ${removalReport.removedEdits.length}
      - Details: ${JSON.stringify(removalReport, null, 2)}`);
    } catch (error) {
      await connection.rollback();
      console.error("Batch deletion failed:", {
        docId,
        error: error.message,
        stack: error.stack,
        timestamp: new Date().toISOString(),
      });
    } finally {
      connection.release();
    }
  });

  socket.on("updateCommentStatus", async ({ docId, commentId, status }) => {
    try {
      // Fetch current elements
      const [documents] = await pool.execute(
        "SELECT elements FROM documents WHERE document_id = ?",
        [docId]
      );

      let currentElements =
        documents[0] && documents[0].elements
          ? JSON.parse(documents[0].elements)
          : { comments: [], suggestedEdits: [] };

      const commentIndex = currentElements.comments.findIndex(
        (comment) => comment.id === commentId
      );

      if (commentIndex !== -1) {
        const oldStatus = currentElements.comments[commentIndex].status;
        currentElements.comments[commentIndex].status = status;

        // Update elements in database
        await pool.execute(
          "UPDATE documents SET elements = ? WHERE document_id = ?",
          [JSON.stringify(currentElements), docId]
        );

        io.to(docId).emit("updateCommentStatus", { commentId, status });

        console.log(`Comment status updated: 
          - Document ID: ${docId}
          - Comment ID: ${commentId}
          - Old Status: ${oldStatus}
          - New Status: ${status}
          - Timestamp: ${new Date().toISOString()}`);
      }
    } catch (error) {
      console.error("Error updating comment status:", error);
    }
  });

  socket.on("updateCommentReplies", async ({ docId, commentId, reply }) => {
    try {
      // Fetch current elements
      const [documents] = await pool.execute(
        "SELECT elements FROM documents WHERE document_id = ?",
        [docId]
      );

      let currentElements =
        documents[0] && documents[0].elements
          ? JSON.parse(documents[0].elements)
          : { comments: [], suggestedEdits: [] };

      const commentIndex = currentElements.comments.findIndex(
        (comment) => comment.id === commentId
      );

      if (commentIndex !== -1) {
        if (!currentElements.comments[commentIndex].replies) {
          currentElements.comments[commentIndex].replies = [];
        }
        currentElements.comments[commentIndex].replies.push(reply);

        // Update elements in database
        await pool.execute(
          "UPDATE documents SET elements = ? WHERE document_id = ?",
          [JSON.stringify(currentElements), docId]
        );

        io.to(docId).emit("updateCommentReplies", { commentId, reply });

        console.log(`Comment reply added: 
          - Document ID: ${docId}
          - Comment ID: ${commentId}
          - Reply Author: ${reply.author}
          - Timestamp: ${new Date().toISOString()}`);
      }
    } catch (error) {
      console.error("Error updating comment replies:", error);
    }
  });

  socket.on(
    "updateSuggestedEditStatus",
    async ({ docId, suggestededitId, status }) => {
      try {
        // Fetch current elements
        const [documents] = await pool.execute(
          "SELECT elements FROM documents WHERE document_id = ?",
          [docId]
        );

        let currentElements =
          documents[0] && documents[0].elements
            ? JSON.parse(documents[0].elements)
            : { comments: [], suggestedEdits: [] };

        const editIndex = currentElements.suggestedEdits.findIndex(
          (edit) => edit.id === suggestededitId
        );

        if (editIndex !== -1) {
          const oldStatus = currentElements.suggestedEdits[editIndex].status;
          currentElements.suggestedEdits[editIndex].status = status;

          // Update elements in database
          await pool.execute(
            "UPDATE documents SET elements = ? WHERE document_id = ?",
            [JSON.stringify(currentElements), docId]
          );

          io.to(docId).emit("updateSuggestedEditStatus", {
            suggestededitId,
            status,
          });

          console.log(`Suggested edit status updated: 
          - Document ID: ${docId}
          - Suggested Edit ID: ${suggestededitId}
          - Old Status: ${oldStatus}
          - New Status: ${status}
          - Timestamp: ${new Date().toISOString()}`);
        }
      } catch (error) {
        console.error("Error removing Suggested edit status:", error);
      }
    }
  );

  socket.on(
    "updateSuggestedEditReplies",
    async ({ docId, suggestededitId, reply }) => {
      try {
        // Fetch current elements
        const [documents] = await pool.execute(
          "SELECT elements FROM documents WHERE document_id = ?",
          [docId]
        );

        let currentElements =
          documents[0] && documents[0].elements
            ? JSON.parse(documents[0].elements)
            : { comments: [], suggestedEdits: [] };

        const suggestededitIndex = currentElements.suggestedEdits.findIndex(
          (suggestededit) => suggestededit.id === suggestededitId
        );

        if (suggestededitIndex !== -1) {
          if (!currentElements.suggestedEdits[suggestededitIndex].replies) {
            currentElements.suggestedEdits[suggestededitIndex].replies = [];
          }
          currentElements.suggestedEdits[suggestededitIndex].replies.push(
            reply
          );

          // Update elements in database
          await pool.execute(
            "UPDATE documents SET elements = ? WHERE document_id = ?",
            [JSON.stringify(currentElements), docId]
          );

          io.to(docId).emit("updateSuggestedEditReplies", {
            suggestededitId,
            reply,
          });

          console.log(`Suggested edit reply added: 
          - Document ID: ${docId}
          - Suggested Edit ID: ${suggestededitId}
          - Reply Author: ${reply.author}
          - Timestamp: ${new Date().toISOString()}`);
        }
      } catch (error) {
        console.error("Error removing Suggested edit replies:", error);
      }
    }
  );

  socket.on("cursorMove", ({ docId, userId, cursorPosition, userName }) => {
    socket.to(docId).emit("cursorUpdate", { userId, cursorPosition, userName });

    console.log(`Cursor moved: 
      - Document ID: ${docId}
      - User ID: ${userId}
      - Username: ${userName}
      - Cursor Position: ${cursorPosition}
      - Timestamp: ${new Date().toISOString()}`);
  });

  socket.on("disconnect", () => {
    console.log(`Socket disconnected: 
      - Socket ID: ${socket.id}
      - Disconnection Timestamp: ${new Date().toISOString()}`);
  });
});

// Start server
const PORT = process.env.PORT || 3000;
cleanupExpiredTokens();
server.listen(PORT, () =>
  console.log(`Server running on http://localhost:${PORT}`)
);
