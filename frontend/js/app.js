// Global app object
window.app = {};

// Configuration handling
const getApiUrl = () => {
    if (window.config && window.config.apiUrl) {
        return window.config.apiUrl;
    }
    // Fallback or development URL
    return 'http://localhost:3000'; // Placeholder
};

// DOM Elements
const postForm = document.getElementById('postForm');
const feed = document.getElementById('feed');
const statusMessage = document.getElementById('statusMessage');
const submitBtn = document.getElementById('submitBtn');

// Helper to show status
const showStatus = (message, type) => {
    if (!statusMessage) return;
    statusMessage.textContent = message;
    statusMessage.className = `status-message ${type}`;
    setTimeout(() => {
        statusMessage.className = 'status-message';
        statusMessage.textContent = '';
    }, 5000);
};

// Submit Post
if (postForm) {
    postForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const formData = {
            name: document.getElementById('name').value,
            message: document.getElementById('message').value
        };

        const originalBtnText = submitBtn.innerHTML;
        submitBtn.innerHTML = '<span class="spinner"></span> Posting...';
        submitBtn.disabled = true;

        try {
            const response = await fetch(`${getApiUrl()}/posts`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            });

            if (!response.ok) {
                throw new Error('Failed to submit post');
            }

            showStatus('Posted successfully!', 'success');
            postForm.reset();
            // Reload feed
            window.app.loadPosts();
        } catch (error) {
            console.error('Error:', error);
            showStatus('Failed to post. Please try again.', 'error');
        } finally {
            submitBtn.innerHTML = originalBtnText;
            submitBtn.disabled = false;
        }
    });
}

// Load Posts
window.app.loadPosts = async () => {
    if (!feed) return;

    try {
        const response = await fetch(`${getApiUrl()}/posts`);

        if (!response.ok) {
            throw new Error('Failed to fetch posts');
        }

        const posts = await response.json();

        feed.innerHTML = '';

        if (posts.length === 0) {
            feed.innerHTML = '<div class="empty-feed">No posts yet. Be the first to share something!</div>';
            return;
        }

        posts.forEach(post => {
            const card = document.createElement('div');
            card.className = 'post-card';

            let date;
            try {
                const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
                date = new Date(post.timestamp).toLocaleString(undefined, {
                    dateStyle: 'medium',
                    timeStyle: 'short',
                    timeZone: timeZone,
                    timeZoneName: 'short'
                });
            } catch (e) {
                console.error('Date formatting error:', e, post);
                date = new Date(post.timestamp).toLocaleString();
            }

            // Generate a random avatar color based on name
            const avatarColor = stringToColor(post.name);
            const initial = post.name.charAt(0).toUpperCase();

            card.innerHTML = `
                <div class="post-header">
                    <div class="avatar" style="background-color: ${avatarColor}">${initial}</div>
                    <div class="post-meta">
                        <div class="post-author">${escapeHtml(post.name)}</div>
                        <div class="post-date">${date}</div>
                    </div>
                </div>
                <div class="post-content">
                    ${escapeHtml(post.message)}
                </div>
            `;
            feed.appendChild(card);
        });

    } catch (error) {
        console.error('Error:', error);
        feed.innerHTML = '<div class="error-feed">Failed to load posts.</div>';
    }
};

// Helper: Generate color from string
function stringToColor(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
        hash = str.charCodeAt(i) + ((hash << 5) - hash);
    }
    const c = (hash & 0x00FFFFFF).toString(16).toUpperCase();
    return '#' + '00000'.substring(0, 6 - c.length) + c;
}

// XSS Prevention
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    window.app.loadPosts();
});
