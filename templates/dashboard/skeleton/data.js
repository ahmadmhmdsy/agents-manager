// Mock data for the dashboard template skeleton (Branch A — in-memory).
// Loaded synchronously by skeleton/index.html so first paint is identical
// to first paint with Branch B (REST) once data hydrates.
//
// Schema (per `memory/03-data-table.md`):
//   id:        string  — stable id, used for remove/edit actions
//   name:      string  — display name; sortable
//   email:     string  — email; sortable; searchable
//   role:      enum    — 'admin' | 'member' | 'viewer'
//   status:    enum    — 'active' | 'invited' | 'disabled'
//   lastSeen:  string  — human-readable timestamp; not sortable in v0.1.0
//   invitedBy: string  — display name; not sortable in v0.1.0

window.MOCK_USERS = [
  { id: 'u-01', name: 'Ali Hassan',      email: 'ali@example.com',     role: 'admin',   status: 'active',   lastSeen: '2 minutes ago',  invitedBy: '—'            },
  { id: 'u-02', name: 'Bo Chen',         email: 'bo@example.com',      role: 'admin',   status: 'active',   lastSeen: '1 hour ago',    invitedBy: 'Ali Hassan'   },
  { id: 'u-03', name: 'Camille Roux',    email: 'camille@example.com', role: 'admin',   status: 'active',   lastSeen: '3 hours ago',   invitedBy: 'Ali Hassan'   },
  { id: 'u-04', name: 'Devon Park',      email: 'devon@example.com',   role: 'member',  status: 'active',   lastSeen: 'just now',      invitedBy: 'Bo Chen'      },
  { id: 'u-05', name: 'Esme Adler',      email: 'esme@example.com',    role: 'member',  status: 'active',   lastSeen: 'yesterday',     invitedBy: 'Bo Chen'      },
  { id: 'u-06', name: 'Finn O\'Brien',   email: 'finn@example.com',    role: 'member',  status: 'invited',  lastSeen: '—',             invitedBy: 'Camille Roux' },
  { id: 'u-07', name: 'Gita Rao',        email: 'gita@example.com',    role: 'member',  status: 'active',   lastSeen: '5 minutes ago', invitedBy: 'Devon Park'   },
  { id: 'u-08', name: 'Hugo Tanaka',     email: 'hugo@example.com',    role: 'viewer',  status: 'active',   lastSeen: '1 day ago',     invitedBy: 'Ali Hassan'   },
  { id: 'u-09', name: 'Ines Vidal',      email: 'ines@example.com',    role: 'viewer',  status: 'active',   lastSeen: '2 days ago',    invitedBy: 'Ali Hassan'   },
  { id: 'u-10', name: 'Jonas Berg',      email: 'jonas@example.com',   role: 'member',  status: 'active',   lastSeen: '30 minutes ago',invitedBy: 'Esme Adler'   },
  { id: 'u-11', name: 'Kira Mensah',     email: 'kira@example.com',    role: 'member',  status: 'active',   lastSeen: '1 hour ago',    invitedBy: 'Bo Chen'      },
  { id: 'u-12', name: 'Lior Mizrahi',    email: 'lior@example.com',    role: 'admin',   status: 'disabled', lastSeen: '3 weeks ago',   invitedBy: '—'            },
  { id: 'u-13', name: 'Maya Singh',      email: 'maya@example.com',    role: 'member',  status: 'active',   lastSeen: '20 minutes ago',invitedBy: 'Devon Park'   },
  { id: 'u-14', name: 'Nadia Volkov',    email: 'nadia@example.com',   role: 'viewer',  status: 'active',   lastSeen: '4 days ago',    invitedBy: 'Camille Roux' },
  { id: 'u-15', name: 'Owen Kane',       email: 'owen@example.com',    role: 'member',  status: 'invited',  lastSeen: '—',             invitedBy: 'Bo Chen'      },
  { id: 'u-16', name: 'Priya Banerjee',  email: 'priya@example.com',   role: 'admin',   status: 'active',   lastSeen: '6 hours ago',   invitedBy: '—'            },
  { id: 'u-17', name: 'Quinn Hale',      email: 'quinn@example.com',   role: 'member',  status: 'active',   lastSeen: '12 hours ago',  invitedBy: 'Maya Singh'   },
  { id: 'u-18', name: 'Ravi Khoury',     email: 'ravi@example.com',    role: 'viewer',  status: 'active',   lastSeen: '1 hour ago',    invitedBy: 'Devon Park'   },
  { id: 'u-19', name: 'Sasha Petrov',    email: 'sasha@example.com',   role: 'member',  status: 'active',   lastSeen: '5 minutes ago', invitedBy: 'Esme Adler'   },
  { id: 'u-20', name: 'Tara Adesanya',   email: 'tara@example.com',    role: 'admin',   status: 'active',   lastSeen: '3 hours ago',   invitedBy: '—'            },
  { id: 'u-21', name: 'Umar Faruq',      email: 'umar@example.com',    role: 'viewer',  status: 'active',   lastSeen: '2 days ago',    invitedBy: 'Priya Banerjee'},
  { id: 'u-22', name: 'Vera Lindberg',   email: 'vera@example.com',    role: 'member',  status: 'active',   lastSeen: '15 minutes ago',invitedBy: 'Gita Rao'     },
  { id: 'u-23', name: 'Wren Halverson',  email: 'wren@example.com',    role: 'member',  status: 'active',   lastSeen: '4 hours ago',   invitedBy: 'Bo Chen'      },
  { id: 'u-24', name: 'Xochitl Romero',  email: 'xochitl@example.com', role: 'admin',   status: 'active',   lastSeen: 'just now',      invitedBy: 'Ali Hassan'   },
  { id: 'u-25', name: 'Yusuf Aydin',     email: 'yusuf@example.com',   role: 'viewer',  status: 'active',   lastSeen: '1 week ago',    invitedBy: 'Lior Mizrahi' }
];

// Mock metrics (3-cell metrics row — `memory/01-builder-flow.md` Stage 2 data shape).
// v0.1.0 ships hand-curated numbers; v0.2.0 will replace with computed values from real data.
window.MOCK_METRICS = {
  mrr:        { value: '$48.2k', delta: '+12.4%',  dir: 'up'   },
  seats:      { value: '184',    delta: '+8.2%',   dir: 'up'   },
  nrr:        { value: '108%',   delta: '-2.1%',   dir: 'down' }
};
