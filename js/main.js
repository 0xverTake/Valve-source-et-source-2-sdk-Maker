document.addEventListener('DOMContentLoaded', function() {
    console.log("DOM fully loaded, initializing web effect...");
    
    // Initialize canvas web effect
    const canvas = document.getElementById('spiderWebCanvas');
    if (canvas) {
        // Initial draw
        initSpiderWebCanvas(canvas);
        
        // Animation variables
        let animationId;
        let opacity = 0;
        const targetOpacity = 0.8;
        const fadeSpeed = 0.01;
        
        // Rotating light effect variables
        let lightAngle = 0;
        const lightSpeed = 0.005; // vitesse de rotation
        
        // Animation function
        function animateWeb() {
            if (opacity < targetOpacity) {
                opacity += fadeSpeed;
                canvas.style.opacity = opacity;
            }
            
            // Mise à jour de l'angle de la lumière rotative
            lightAngle += lightSpeed;
            if (lightAngle > Math.PI * 2) {
                lightAngle = 0;
            }
            
            // Redessiner l'effet avec la nouvelle position de lumière
            const ctx = canvas.getContext('2d');
            drawSpiderWeb(ctx, canvas.width, canvas.height, lightAngle);
            
            animationId = requestAnimationFrame(animateWeb);
        }
        
        // Start animation
        animateWeb();
        
        // Resize handler for canvas
        window.addEventListener('resize', function() {
            // Cancel current animation
            if (animationId) {
                cancelAnimationFrame(animationId);
            }
            
            // Redraw and restart animation
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
            opacity = 0;
            animateWeb();
        });
    } else {
        console.error("Spider web canvas element not found!");
    }
    
    // Tab functionality for documentation section
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabPanes = document.querySelectorAll('.tab-pane');
    
    tabBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            // Remove active class from all buttons and panes
            tabBtns.forEach(b => b.classList.remove('active'));
            tabPanes.forEach(p => p.classList.remove('active'));
            
            // Add active class to clicked button
            this.classList.add('active');
            
            // Show corresponding tab pane
            const tabId = this.getAttribute('data-tab');
            document.getElementById(tabId).classList.add('active');
        });
    });
    
    // Smooth scrolling for navigation links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            
            // Vérifier si targetId est valide (pas juste '#')
            if (targetId === '#' || targetId === '') {
                return; // Ne rien faire si le lien est juste '#' ou vide
            }
            
            const targetElement = document.querySelector(targetId);
            
            if (targetElement) {
                window.scrollTo({
                    top: targetElement.offsetTop - 80,
                    behavior: 'smooth'
                });
                
                // Update active nav link
                document.querySelectorAll('nav a').forEach(navLink => {
                    navLink.classList.remove('active');
                });
                this.classList.add('active');
            }
        });
    });
    
    // Update active nav link on scroll
    window.addEventListener('scroll', function() {
        // Ne pas recréer l'effet de toile d'araignée lors du défilement
        // Mettre à jour uniquement les liens de navigation
        
        const scrollPosition = window.scrollY;
        
        document.querySelectorAll('section').forEach(section => {
            const sectionTop = section.offsetTop - 100;
            const sectionBottom = sectionTop + section.offsetHeight;
            const sectionId = section.getAttribute('id');
            
            if (scrollPosition >= sectionTop && scrollPosition < sectionBottom) {
                document.querySelectorAll('nav a').forEach(navLink => {
                    navLink.classList.remove('active');
                    if (navLink.getAttribute('href') === `#${sectionId}`) {
                        navLink.classList.add('active');
                    }
                });
            }
        });
    });
    
    // Form submission handling
    const newsletterForm = document.querySelector('.footer-newsletter form');
    if (newsletterForm) {
        newsletterForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const emailInput = this.querySelector('input[type="email"]');
            const email = emailInput.value.trim();
            
            if (email && validateEmail(email)) {
                // Here you would typically send the email to your server
                alert(`Merci de vous être abonné avec l'email: ${email}`);
                emailInput.value = '';
            } else {
                alert('Veuillez entrer une adresse email valide.');
            }
        });
    }
    
    // Email validation helper
    function validateEmail(email) {
        const re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(String(email).toLowerCase());
    }
    
    // Add animation on scroll
    const animateElements = document.querySelectorAll('.feature-card, .tool-content, .tool-image, .download-card');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, { threshold: 0.1 });
    
    animateElements.forEach(element => {
        element.style.opacity = '0';
        element.style.transform = 'translateY(20px)';
        element.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
        observer.observe(element);
    });
});

// Add this function to create the spider web effect
function initSpiderWebCanvas(canvas) {
    console.log("Initializing spider web canvas...");
    
    // Get canvas context
    const ctx = canvas.getContext('2d');
    
    // Set canvas dimensions
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    
    // Initial draw
    drawSpiderWeb(ctx, canvas.width, canvas.height, 0);
}

function drawSpiderWeb(ctx, width, height, lightAngle) {
    // Clear canvas
    ctx.clearRect(0, 0, width, height);
    
    const centerX = width / 2;
    const centerY = height / 2;
    
    // Draw rotating light effect first (so it's behind the web)
    const lightX = centerX + Math.cos(lightAngle) * (width * 0.4);
    const lightY = centerY + Math.sin(lightAngle) * (height * 0.4);
    
    // Create radial gradient for light
    const gradient = ctx.createRadialGradient(
        lightX, lightY, 0,
        lightX, lightY, Math.min(width, height) * 0.5
    );
    gradient.addColorStop(0, 'rgba(255, 255, 255, 0.6)');
    gradient.addColorStop(0.2, 'rgba(255, 255, 255, 0.3)');
    gradient.addColorStop(1, 'rgba(255, 255, 255, 0)');
    
    // Draw light
    ctx.beginPath();
    ctx.arc(lightX, lightY, Math.min(width, height) * 0.5, 0, Math.PI * 2);
    ctx.fillStyle = gradient;
    ctx.fill();
    
    // Ajouter un second effet de lumière plus petit qui tourne dans le sens inverse
    const lightAngle2 = -lightAngle * 1.5;
    const lightX2 = centerX + Math.cos(lightAngle2) * (width * 0.3);
    const lightY2 = centerY + Math.sin(lightAngle2) * (height * 0.3);
    
    const gradient2 = ctx.createRadialGradient(
        lightX2, lightY2, 0,
        lightX2, lightY2, Math.min(width, height) * 0.3
    );
    gradient2.addColorStop(0, 'rgba(200, 230, 255, 0.5)');
    gradient2.addColorStop(0.3, 'rgba(200, 230, 255, 0.2)');
    gradient2.addColorStop(1, 'rgba(200, 230, 255, 0)');
    
    ctx.beginPath();
    ctx.arc(lightX2, lightY2, Math.min(width, height) * 0.3, 0, Math.PI * 2);
    ctx.fillStyle = gradient2;
    ctx.fill();
    
    // Draw radial web lines (circles)
    const numRadials = 12;
    for (let j = 1; j <= 8; j++) {
        const radius = j * (Math.min(width, height) * 0.05);
        ctx.beginPath();
        ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
        ctx.lineWidth = 1;
        
        // Faire briller les cercles près de la lumière
        const distToLight = Math.sqrt(
            Math.pow(centerX - lightX, 2) + Math.pow(centerY - lightY, 2)
        );
        const brightness = Math.max(0.15, 0.4 - (distToLight / (width * 0.5)));
        
        ctx.strokeStyle = `rgba(255, 255, 255, ${brightness})`;
        ctx.stroke();
    }
    
    // Draw spider web lines
    const numLines = 50;
    for (let i = 0; i < numLines; i++) {
        const angle = (i / numLines) * Math.PI * 2;
        const length = Math.random() * (Math.min(width, height) * 0.7);
        const thickness = Math.random() * 1.5 + 0.5;
        
        // Calculer la distance à la lumière
        const endX = centerX + Math.cos(angle) * length;
        const endY = centerY + Math.sin(angle) * length;
        const distToLight = Math.min(
            Math.sqrt(Math.pow(endX - lightX, 2) + Math.pow(endY - lightY, 2)),
            Math.sqrt(Math.pow(endX - lightX2, 2) + Math.pow(endY - lightY2, 2))
        );
        
        // Ajuster la luminosité en fonction de la distance à la lumière
        const brightness = Math.max(0.2, 0.5 - (distToLight / (width * 0.5)));
        
        // Draw line on canvas with gradient
        const lineGradient = ctx.createLinearGradient(
            centerX, centerY,
            endX, endY
        );
        lineGradient.addColorStop(0, `rgba(255, 255, 255, ${brightness * 0.1})`);
        lineGradient.addColorStop(0.5, `rgba(255, 255, 255, ${brightness})`);
        lineGradient.addColorStop(1, `rgba(255, 255, 255, ${brightness * 0.1})`);
        
        ctx.beginPath();
        ctx.moveTo(centerX, centerY);
        ctx.lineTo(endX, endY);
        ctx.lineWidth = thickness;
        ctx.strokeStyle = lineGradient;
        ctx.stroke();
    }
    
    // Add some random small connecting lines between the radials
    for (let i = 0; i < 30; i++) {
        const angle1 = Math.random() * Math.PI * 2;
        const angle2 = angle1 + (Math.random() * 0.5 - 0.25);
        const radius1 = Math.random() * (Math.min(width, height) * 0.3);
        const radius2 = radius1 + (Math.random() * 50 - 25);
        
        const x1 = centerX + Math.cos(angle1) * radius1;
        const y1 = centerY + Math.sin(angle1) * radius1;
        const x2 = centerX + Math.cos(angle2) * radius2;
        const y2 = centerY + Math.sin(angle2) * radius2;
        
        // Calculer la distance à la lumière
        const distToLight = Math.min(
            Math.sqrt(Math.pow(x1 - lightX, 2) + Math.pow(y1 - lightY, 2)),
            Math.sqrt(Math.pow(x2 - lightX2, 2) + Math.pow(y2 - lightY2, 2))
        );
        
        // Ajuster la luminosité en fonction de la distance à la lumière
        const brightness = Math.max(0.1, 0.3 - (distToLight / (width * 0.5)));
        
        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y2);
        ctx.lineWidth = 0.5;
        ctx.strokeStyle = `rgba(255, 255, 255, ${brightness})`;
        ctx.stroke();
    }
    
    // Add a highlight effect where the light is
    ctx.beginPath();
    ctx.arc(lightX, lightY, 5, 0, Math.PI * 2);
    ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
    ctx.fill();
    
    // Ajouter un halo autour de la lumière principale
    ctx.beginPath();
    ctx.arc(lightX, lightY, 15, 0, Math.PI * 2);
    ctx.fillStyle = 'rgba(255, 255, 255, 0.4)';
    ctx.fill();
    
    // Ajouter un highlight pour la seconde lumière
    ctx.beginPath();
    ctx.arc(lightX2, lightY2, 3, 0, Math.PI * 2);
    ctx.fillStyle = 'rgba(200, 230, 255, 0.7)';
    ctx.fill();
}
